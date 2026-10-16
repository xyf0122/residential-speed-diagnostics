# Draw saved aggregate summaries; no estimation or resampling.
suppressPackageStartupMessages({library(ggplot2);library(patchwork);library(grid);library(jsonlite)})
args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2)
D<-normalizePath(args[1]);W<-args[2];dir.create(W,recursive=TRUE,showWarnings=FALSE)
font_family<-Sys.getenv("AAP_FONT",if(capabilities("aqua")) "Arial" else "Helvetica")
do.call(grDevices::pdfFonts,setNames(list(grDevices::pdfFonts()$Helvetica),font_family))
grDevices::pdf(file=NULL,family=font_family)
d<-read.csv(file.path(D,'roughness.csv'),stringsAsFactors=FALSE,colClasses=c(G_display='character',G_range_display='character',L_display='character',L_range_display='character'));rids<-d$rid;cols<-c(a='#4B7FA3',b='#8B729A',c='#298A83')
base<-theme_classic(base_size=7.2,base_family=font_family)+theme(axis.line=element_line(linewidth=.8/ggplot2::.pt),axis.ticks=element_line(linewidth=.8/ggplot2::.pt),axis.ticks.length=unit(2.5,'pt'),axis.text=element_text(size=7.2,colour='#1F1F1F'),axis.title=element_text(size=8),plot.title=element_text(size=8,face='plain',colour='#1F1F1F',margin=margin(b=8)),plot.title.position='plot',plot.margin=margin(4,6,7,5),plot.tag=element_text(size=10,face='bold',colour='black',hjust=0,vjust=1),plot.tag.position='topleft',plot.tag.location='margin',legend.position='none')
d$pointfill<-ifelse(d$status=='descriptive','white','#B8D5E2')
d$lx<-c(.826,.867,.935,1.022,.930,.810,.752,.670);d$ly<-c(2.84,1.03,.535,1.49,1.87,2.03,.87,1.77)
ci<-d[!is.na(d$E_lower),]
p1<-ggplot()+
 geom_errorbar(data=ci,aes(xmin=E_lower,xmax=E_upper,y=J),orientation='y',width=.045,linewidth=.8/ggplot2::.pt,colour='#7CA7BE')+
 geom_errorbar(data=ci,aes(ymin=J_lower,ymax=J_upper,x=E),width=.008,linewidth=.8/ggplot2::.pt,colour='#7CA7BE')+
 geom_segment(data=d,aes(x=E,y=J,xend=lx,yend=ly),linewidth=.45/ggplot2::.pt,colour='#ADB4B8')+
 geom_point(data=d,aes(x=E,y=J,shape=status,fill=pointfill),size=1.9,stroke=.5,colour=cols[['a']])+
 geom_text(data=d,aes(x=lx,y=ly,label=rid),family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F',vjust=.5)+
 scale_shape_manual(values=c(primary=21,descriptive=23),guide='none')+scale_fill_identity()+
 scale_x_continuous(limits=c(.6,1.05),breaks=c(.6,.7,.8,.9,1),expand=expansion(mult=0))+
 scale_y_continuous(limits=c(.4,3.25),breaks=c(.5,1,1.5,2,2.5,3),expand=expansion(mult=0))+
 labs(title='Index and reconstructed roughness',x=expression(italic(E)),y=expression('Median'~italic(J)))+base
# B: a three-column numeric heatmap of the saved G summaries.
mat<-rbind(data.frame(rid=d$rid,y=d$y,x=1,value=d$G_lower,role='Lower'),data.frame(rid=d$rid,y=d$y,x=2,value=d$G,role='Median'),data.frame(rid=d$rid,y=d$y,x=3,value=d$G_upper,role='Upper'))
mat$label<-ifelse(is.na(mat$value),'—',sprintf('%.4f',mat$value))
p2<-ggplot()+
 geom_tile(data=mat,aes(x=x,y=y,fill=value),width=.94,height=.88,colour='white',linewidth=.4)+
 geom_text(data=mat,aes(x=x,y=y,label=label,vjust=ifelse(is.na(value),.36,.5)),family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
 scale_fill_gradient(low='#EDF3F8',high='#779BB5',limits=c(.01,.025),na.value='#F3F3F3',name=expression(italic(G)~'(model'~s^{-2}*')'),breaks=c(.01,.015,.02,.025),guide='none')+
 scale_x_continuous(limits=c(.45,4.65),breaks=1:3,labels=c('Lower 95%','Median','Upper 95%'),expand=expansion(mult=0),position='top')+
 scale_y_continuous(limits=c(-.6,7.6),breaks=0:7,labels=rev(rids),expand=expansion(mult=0))+
 labs(title='Gradient: estimate and uncertainty',x=NULL,y=NULL)+base+
 theme(axis.line=element_blank(),axis.ticks=element_blank())+
 annotation_custom(rectGrob(gp=gpar(col=NA,fill=linearGradient(scales::seq_gradient_pal('#EDF3F8','#779BB5','Lab')(seq(0,1,length.out=256)),x1=.5,y1=0,x2=.5,y2=1))),xmin=3.63,xmax=3.76,ymin=-.44,ymax=7.44)+
 annotate('text',x=3.87,y=-.44+c(0,1/3,2/3,1)*7.88,label=c('0.010','0.015','0.020','0.025'),hjust=0,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
 annotate('text',x=4.51,y=3.5,label="italic(G)~'(model'~s^{-2}*')'",parse=TRUE,angle=90,family=font_family,size=8/ggplot2::.pt,colour='#1F1F1F')
# C: three parallel quantile axes; straight guides preserve acquisition identity.
qcolors<-c(r1='#3E7296',r13='#8D6B91',r15='#B88B42',r16='#588E83',r17='#B96B6B',r18='#4C938E',r19='#757A82',r20='#9B825F')
qlong<-rbind(data.frame(rid=d$rid,x=1,value=d$L_lower,role='Q1'),data.frame(rid=d$rid,x=2,value=d$L,role='Median'),data.frame(rid=d$rid,x=3,value=d$L_upper,role='Q3'))
qlong$rid<-factor(qlong$rid,levels=rids);qlong$shape<-ifelse(qlong$rid=='r19' & qlong$x==2,23,21);qlong$fillcol<-ifelse(qlong$x==2 & qlong$rid!='r19',qcolors[as.character(qlong$rid)],'white')
lab<-data.frame(rid=rids,value=d$L_upper,label_y=c(143,173,158,109,188,203,94,128))
p3<-ggplot()+
 annotate('segment',x=1:3,xend=1:3,y=45,yend=180,colour='#D6DBDE',linewidth=.55/ggplot2::.pt)+
 geom_line(data=qlong,aes(x=x,y=value,group=rid,colour=rid),linewidth=.8/ggplot2::.pt)+
 geom_point(data=qlong,aes(x=x,y=value,colour=rid,fill=fillcol,shape=shape),size=1.6,stroke=.4)+
 geom_segment(data=lab,aes(x=3.03,xend=3.30,y=value,yend=label_y,colour=rid),linewidth=.5/ggplot2::.pt)+
 geom_text(data=lab,aes(x=3.35,y=label_y,label=rid),hjust=0,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
 scale_colour_manual(values=qcolors,guide='none')+scale_fill_identity()+scale_shape_identity()+
 scale_x_continuous(limits=c(.75,3.85),breaks=1:3,labels=c('Q1','Median','Q3'),expand=expansion(mult=0))+
 scale_y_continuous(limits=c(40,215),breaks=c(50,100,150,200),expand=expansion(mult=0))+
 labs(title='Fitted-span quantile profiles',x=NULL,y=expression(italic(L)~'(model m)'))+base+theme(axis.line.x=element_blank(),axis.ticks.x=element_blank())
# D: common zero-based count scale; paired bars retain distinct populations.
pop<-rbind(data.frame(rid=d$rid,y=d$y+.20,count=d$field_tracks,population='Field tracks',fill='#8DAFC1'),data.frame(rid=d$rid,y=d$y-.20,count=d$accepted_fit,population='Accepted fits',fill='#C8AA7C'))
pop$label<-format(pop$count,big.mark=',',trim=TRUE,scientific=FALSE)
p4<-ggplot()+
 geom_rect(data=pop,aes(xmin=0,xmax=count,ymin=y-.14,ymax=y+.14,fill=fill),colour=NA)+scale_fill_identity()+
 geom_text(data=pop,aes(x=count+240,y=y,label=label,vjust=ifelse(grepl(',',label),.4,.5)),hjust=0,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
 scale_x_continuous(limits=c(0,20500),breaks=c(0,5000,10000,15000,20000),labels=c('0','5,000','10,000','15,000','20,000'),expand=expansion(mult=0))+
 scale_y_continuous(limits=c(-.6,7.6),breaks=0:7,labels=rev(rids),expand=expansion(mult=0))+
 labs(title='Observation populations',x='Number of tracks',y=NULL)+base+theme(axis.line.y=element_blank(),axis.ticks.y=element_blank())
plots<-list(p1,p2,p3,p4);builds<-lapply(plots,function(p)lapply(ggplot_build(p)$data,as.data.frame));names(builds)<-letters[1:4]
keyg<-grobTree(
 pointsGrob(x=unit(c(.04,.29),'npc'),y=unit(rep(.6,2),'npc'),pch=c(21,23),size=unit(1.6,'mm'),gp=gpar(col='#333333',fill=c('#333333','white'),lwd=.6)),
 rectGrob(x=unit(c(.62,.83),'npc'),y=.6,width=unit(3.2,'mm'),height=unit(1.6,'mm'),gp=gpar(fill=c('#8DAFC1','#C8AA7C'),col=NA)),
 textGrob(c('Primary estimate','r19: 4-day descriptive','Field tracks','Accepted fits'),x=unit(c(.06,.31,.645,.855),'npc'),y=unit(rep(.6,4),'npc'),just='left',gp=gpar(fontfamily=font_family,fontsize=7.2,col='#1F1F1F')))
final<-wrap_plots(plots,ncol=2,byrow=TRUE)/wrap_elements(full=keyg,ignore_tag=TRUE)+plot_layout(heights=c(1,.055))+plot_annotation(tag_levels='a',theme=theme(plot.background=element_rect(fill='white',colour=NA)))
pdf_device<-function(filename,width,height,...)if(capabilities("aqua")) grDevices::quartz(file=filename,type="pdf",width=width,height=height,...) else grDevices::pdf(file=filename,width=width,height=height,encoding="WinAnsi.enc",useDingbats=FALSE,...)
ggsave(file.path(W,'Figure7.pdf'),final,device=pdf_device,width=165.9,height=150,units='mm',family=font_family,bg='white')
write_json(builds,file.path(W,'rendered_layers.json'),pretty=TRUE,digits=17,na='null');write_json(pop,file.path(W,'count_labels.json'),pretty=TRUE,digits=17,na='null')

write_json(mat,file.path(W,'gradient_cells.json'),pretty=TRUE,digits=17,na='null')
write_json(qlong,file.path(W,'quantile_nodes.json'),pretty=TRUE,digits=17,na='null')
write_json(list(width_mm=165.9,height_mm=150,panels=list(a=list(xlim=c(.6,1.05),ylim=c(.4,3.25)),b=list(xlim=c(.45,3.55),ylim=c(-.6,7.6)),c=list(xlim=c(.75,3.85),ylim=c(40,215)),d=list(xlim=c(0,20500),ylim=c(-.6,7.6))),qcolors=qcolors,heatmap_limits=c(.01,.025),no_estimation=TRUE),file.path(W,'plot_settings.json'),pretty=TRUE)
