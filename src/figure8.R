# Draw saved aggregate summaries; no estimation or resampling.
suppressPackageStartupMessages({library(ggplot2);library(patchwork);library(grid);library(jsonlite)})
args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2)
D<-normalizePath(args[1]);W<-args[2];dir.create(W,recursive=TRUE,showWarnings=FALSE)
font_family<-Sys.getenv("AAP_FONT",if(capabilities("aqua")) "Arial" else "Helvetica")
do.call(grDevices::pdfFonts,setNames(list(grDevices::pdfFonts()$Helvetica),font_family))
grDevices::pdf(file=NULL,family=font_family)
d<-read.csv(file.path(D,'roughness.csv'),stringsAsFactors=FALSE,colClasses=c(G_display='character',G_range_display='character',L_display='character',L_range_display='character'));rids<-d$rid
base<-theme_classic(base_size=7.2,base_family=font_family)+theme(axis.line=element_line(linewidth=.65/ggplot2::.pt),axis.ticks=element_line(linewidth=.65/ggplot2::.pt),axis.ticks.length=unit(2,'pt'),axis.text=element_text(size=7.2,colour='#26323B'),axis.title=element_text(size=8),plot.title=element_text(size=8,face='plain',colour='#26323B',margin=margin(b=7)),plot.title.position='plot',plot.margin=margin(5,7,6,5),plot.tag=element_text(size=10,face='bold',colour='black',hjust=0,vjust=1),plot.tag.position='topleft',plot.tag.location='margin',legend.position='bottom',legend.text=element_text(size=7),legend.title=element_text(size=7.2),legend.margin=margin(3,0,0,0),legend.key.height=unit(3,'mm'),legend.key.width=unit(4,'mm'),legend.spacing.x=unit(2,'mm'))
# a: numerical table heatmap, common continuous magnitude scale, no centering or rescaling of data.
heatcols<-c('#F6EDCE','#B6D7C4','#69B2B5','#477FA5','#56527D')
mat<-rbind(data.frame(rid=d$rid,y=d$y,x=1,value=d$G_lower,role='Lower'),data.frame(rid=d$rid,y=d$y,x=2,value=d$G,role='Median'),data.frame(rid=d$rid,y=d$y,x=3,value=d$G_upper,role='Upper'))
mat$label<-ifelse(is.na(mat$value),'—',sprintf('%.4f',mat$value))
# Choose black/white cell text by contrast, without changing the fill scale.
cellcol<-scales::gradient_n_pal(heatcols)(scales::rescale(mat$value,from=c(.010,.025)))
mat$textcol<-vapply(cellcol,function(cc){if(is.na(cc))return('#53616A');z<-as.numeric(col2rgb(cc))/255;z<-ifelse(z<=.04045,z/12.92,((z+.055)/1.055)^2.4);if(sum(z*c(.2126,.7152,.0722))<.179)'white' else '#1B2831'},character(1))
p2<-ggplot()+
 geom_tile(data=mat,aes(x=x,y=y,fill=value),width=.96,height=.92,colour='white',linewidth=.35)+
 geom_text(data=mat,aes(x=x,y=y,label=label,colour=textcol),family=font_family,size=7.2/ggplot2::.pt)+scale_colour_identity()+
 annotate('segment',x=.50,xend=3.50,y=c(7.57,-.57),yend=c(7.57,-.57),linewidth=.6/ggplot2::.pt,colour='#47535C')+
 scale_fill_gradientn(colours=heatcols,limits=c(.010,.025),na.value='#EEF0F2',breaks=c(.010,.015,.020,.025),labels=c('0.010','0.015','0.020','0.025'),name=expression(italic(G)~'(model'~s^{-2}*')'),guide=guide_colourbar(direction='vertical',title.position='right',title.hjust=.5,barwidth=unit(2.7,'mm'),barheight=unit(36,'mm'),ticks.colour='#53616A',frame.colour=NA))+
 scale_x_continuous(limits=c(.45,3.55),breaks=1:3,labels=c('Lower 95%','Median','Upper 95%'),expand=expansion(mult=0),position='top')+
 scale_y_continuous(limits=c(-.65,7.65),breaks=0:7,labels=rev(rids),expand=expansion(mult=0))+
 labs(title=NULL,x=NULL,y=NULL)+base+
 theme(axis.line=element_blank(),axis.ticks=element_blank(),axis.text.x=element_text(face='bold',size=7.2,margin=margin(b=4)),legend.position='right',legend.title=element_text(size=7.2,angle=90),legend.margin=margin(0,0,0,4),legend.box.margin=margin(0,0,0,0))
# b: directly labeled acquisition colors; open quartiles, filled primary medians, open r19 diamond.
qcolors<-c(r1='#4477AA',r13='#AA3377',r15='#B68A35',r16='#228833',r17='#CC6677',r18='#3297B5',r19='#666B73',r20='#7762A3')
qlong<-rbind(data.frame(rid=d$rid,x=1,value=d$L_lower,role='Q1'),data.frame(rid=d$rid,x=2,value=d$L,role='Median'),data.frame(rid=d$rid,x=3,value=d$L_upper,role='Q3'))
qlong$rid<-factor(qlong$rid,levels=rids)
qlong$stat<-factor(ifelse(qlong$x!=2,'Q1/Q3',ifelse(qlong$rid=='r19','r19 median','Median')),levels=c('Q1/Q3','Median','r19 median'))
qlong$fillcol<-ifelse(qlong$x==2 & qlong$rid!='r19',qcolors[as.character(qlong$rid)],'white')
lab<-data.frame(rid=rids,value=d$L_upper,label_y=c(143,173,158,109,188,203,94,128))
p3<-ggplot()+
 annotate('segment',x=1:3,xend=1:3,y=45,yend=180,colour='#D6DBDE',linewidth=.55/ggplot2::.pt)+
 geom_line(data=qlong,aes(x=x,y=value,group=rid,colour=rid),linewidth=1.0/ggplot2::.pt)+
 geom_point(data=qlong,aes(x=x,y=value,colour=rid,fill=fillcol,shape=stat),size=1.8,stroke=.45)+
 geom_segment(data=lab,aes(x=3.03,xend=3.30,y=value,yend=label_y,colour=rid),linewidth=.65/ggplot2::.pt)+
 geom_text(data=lab,aes(x=3.35,y=label_y,label=rid,colour=rid),hjust=0,family=font_family,size=7.2/ggplot2::.pt)+
 scale_colour_manual(values=qcolors,guide='none')+scale_fill_identity()+
 scale_shape_manual(name=NULL,values=c('Q1/Q3'=21,Median=21,'r19 median'=23),guide=guide_legend(nrow=1,override.aes=list(fill=c('white','#485762','white'),colour='#485762',size=1.8)))+
 scale_x_continuous(limits=c(.75,3.85),breaks=1:3,labels=c('Q1','Median','Q3'),expand=expansion(mult=0))+
 scale_y_continuous(limits=c(40,215),breaks=c(50,100,150,200),expand=expansion(mult=0))+
 labs(title=NULL,x=NULL,y=expression(italic(L)~'(model m)'))+base+theme(axis.line.x=element_blank(),axis.ticks.x=element_blank(),legend.text=element_text(size=6.8),legend.key.width=unit(3,'mm'))
# c: exact counts on a zero-based axis; status is shown at every bar end and in its own key.
popcols<-c('Field tracks'='#7D9FB8','Accepted fits'='#C6A16B')
pop<-rbind(data.frame(rid=d$rid,y=d$y+.20,count=d$field_tracks,population='Field tracks',status=d$status),data.frame(rid=d$rid,y=d$y-.20,count=d$accepted_fit,population='Accepted fits',status=d$status))
pop$population<-factor(pop$population,levels=names(popcols));pop$status<-factor(pop$status,levels=c('primary','descriptive'))
pop$label<-format(pop$count,big.mark=',',trim=TRUE,scientific=FALSE)
pop$pointfill<-ifelse(pop$status=='primary',popcols[as.character(pop$population)],'white')
band<-data.frame(y=c(7,5,3,1))
p4<-ggplot()+
 geom_rect(data=band,aes(xmin=0,xmax=20500,ymin=y-.48,ymax=y+.48),fill='#F5F6F7',colour=NA)+
 geom_rect(data=pop,aes(xmin=0,xmax=count,ymin=y-.13,ymax=y+.13,fill=population),colour=NA,show.legend=c(fill=TRUE,shape=FALSE))+
 geom_point(data=pop,aes(x=count,y=y,shape=status),fill=pop$pointfill,colour='#485762',size=1.6,stroke=.4,show.legend=c(shape=TRUE,fill=FALSE))+
 geom_text(data=pop,aes(x=count+285,y=y,label=label),hjust=0,family=font_family,size=7.2/ggplot2::.pt,colour='#26323B')+
 scale_fill_manual(name=NULL,values=popcols,guide=guide_legend(order=1,override.aes=list(colour=NA)))+
 scale_shape_manual(name=NULL,values=c(primary=21,descriptive=23),labels=c('Primary acquisition','r19: 4-day descriptive'),guide=guide_legend(order=2,override.aes=list(fill=c('#485762','white'),colour='#485762')))+
 scale_x_continuous(limits=c(0,20500),breaks=c(0,5000,10000,15000,20000),labels=c('0','5,000','10,000','15,000','20,000'),expand=expansion(mult=0))+
 scale_y_continuous(limits=c(-.6,7.6),breaks=0:7,labels=rev(rids),expand=expansion(mult=0))+
 labs(title=NULL,x='Number of tracks',y=NULL)+base+theme(axis.line.y=element_blank(),axis.ticks.y=element_blank(),legend.box='horizontal',legend.spacing.x=unit(3,'mm'))
final<-wrap_plots(p2,p3,p4,design='AB\nCC',heights=c(1.05,1))+plot_annotation(tag_levels='a',theme=theme(plot.background=element_rect(fill='white',colour=NA)))
pdf_device<-function(filename,width,height,...)if(capabilities("aqua")) grDevices::quartz(file=filename,type="pdf",width=width,height=height,...) else grDevices::pdf(file=filename,width=width,height=height,encoding="WinAnsi.enc",useDingbats=FALSE,...)
ggsave(file.path(W,'Figure8.pdf'),final,device=pdf_device,width=165.9,height=150,units='mm',family=font_family,bg='white')
# Export marks from the same plot objects that generated the figure.
write_json(mat,file.path(W,'gradient_cells.json'),digits=17,na='null')
write_json(qlong,file.path(W,'quantile_nodes.json'),digits=17)
write_json(pop,file.path(W,'count_labels.json'),digits=17)
builds <- lapply(list(a=p2, b=p3, c=p4), function(p) lapply(ggplot_build(p)$data, as.data.frame))
write_json(builds,file.path(W,'rendered_layers.json'),digits=17,na='null')
