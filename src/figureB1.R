# Draw saved aggregate summaries; no estimation or resampling.
suppressPackageStartupMessages({library(ggplot2);library(patchwork);library(grid);library(jsonlite)})
args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2)
D<-normalizePath(args[1]);W<-args[2];dir.create(W,recursive=TRUE,showWarnings=FALSE)
font_family<-Sys.getenv("AAP_FONT",if(capabilities("aqua")) "Arial" else "Helvetica")
do.call(grDevices::pdfFonts,setNames(list(grDevices::pdfFonts()$Helvetica),font_family))
grDevices::pdf(file=NULL,family=font_family)
d<-read.csv(file.path(D,'scenario.csv'),colClasses=c(display='character'));rids<-unique(d$rid)
base<-theme_classic(base_size=7.2,base_family=font_family)+theme(axis.line=element_line(linewidth=.8/ggplot2::.pt),axis.line.y=element_blank(),axis.ticks=element_line(linewidth=.8/ggplot2::.pt),axis.ticks.y=element_blank(),axis.ticks.length=unit(2.5,'pt'),axis.text=element_text(size=7.2,colour='#1F1F1F'),axis.title=element_text(size=8),plot.title=element_text(size=8,face='plain',colour='#1F1F1F',margin=margin(b=8)),plot.title.position='plot',plot.margin=margin(4,7,7,5),plot.tag=element_text(size=10,face='bold',colour='black',hjust=0,vjust=1),plot.tag.position='topleft',plot.tag.location='margin',legend.position='none')
configs<-list(a=list(title='Index under capping',xlabel=expression(italic(E)),limits=c(-.10,1.10),ticks=c(0,.25,.5,.75,1)),b=list(title='Uncapped average excess',xlabel=expression('Uncapped'~italic(A)~'(conditional mph)'),limits=c(-1.5,15.8),ticks=c(0,5,10,15)),c=list(title='Capped support fraction',xlabel='Retained-length fraction',limits=c(-.10,1.10),ticks=c(0,.25,.5,.75,1)),d=list(title='Maximum uncapped overshoot',xlabel='Overshoot (conditional mph)',limits=c(-1.5,17.4),ticks=c(0,5,10,15)))
plots<-list();builds<-list()
for(key in names(configs)){
 cf<-configs[[key]];dd<-d[d$panel==key,];p<-dd[dd$spec=='primary',];s<-dd[dd$spec=='scenario',];stopifnot(identical(p$rid,s$rid));p$scenario_x<-s$x
 g<-ggplot()+
 geom_segment(data=p,aes(x=x,xend=scenario_x,y=y,yend=y),colour='#B9C2C6',linewidth=.8/ggplot2::.pt)+
 geom_label(data=p,aes(x=x,y=y,label=display),family=font_family,size=7.2/ggplot2::.pt,fill='#DFEDF0',colour='#356E80',text.colour='#1F1F1F',linewidth=.65/ggplot2::.pt,label.padding=unit(c(2.2,2.8),'pt'),label.r=unit(5,'pt'))+
 geom_label(data=s,aes(x=x,y=y,label=display),family=font_family,size=7.2/ggplot2::.pt,fill='#F3DFE4',colour='#B15770',text.colour='#1F1F1F',linewidth=.65/ggplot2::.pt,label.padding=unit(c(2.2,2.8),'pt'),label.r=unit(.5,'pt'))+
 scale_x_continuous(limits=cf$limits,breaks=cf$ticks,expand=expansion(mult=0))+
 scale_y_continuous(limits=c(-.6,7.6),breaks=0:7,labels=rev(rids),expand=expansion(mult=0))+
 labs(title=cf$title,x=cf$xlabel,y=NULL)+base
 plots[[key]]<-g;builds[[key]]<-lapply(ggplot_build(g)$data,as.data.frame)
}
keyg<-grobTree(roundrectGrob(x=.31,y=.5,width=unit(5,'mm'),height=unit(3,'mm'),r=unit(1.5,'mm'),gp=gpar(fill='#DFEDF0',col='#356E80',lwd=.6)),roundrectGrob(x=.54,y=.5,width=unit(5,'mm'),height=unit(3,'mm'),r=unit(.18,'mm'),gp=gpar(fill='#F3DFE4',col='#B15770',lwd=.6)),textGrob(c('Primary','Joint-scale scenario'),x=c(.335,.565),y=.5,just='left',gp=gpar(fontfamily=font_family,fontsize=7.2,col='#1F1F1F')))
final<-wrap_plots(plots,ncol=2,byrow=TRUE)/wrap_elements(full=keyg,ignore_tag=TRUE)+plot_layout(heights=c(1,.05))+plot_annotation(tag_levels='a',theme=theme(plot.background=element_rect(fill='white',colour=NA)))
pdf_device<-function(filename,width,height,...)if(capabilities("aqua")) grDevices::quartz(file=filename,type="pdf",width=width,height=height,...) else grDevices::pdf(file=filename,width=width,height=height,encoding="WinAnsi.enc",useDingbats=FALSE,...)
ggsave(file.path(W,'FigureB1.pdf'),final,device=pdf_device,width=165.9,height=140,units='mm',family=font_family,bg='white')
write_json(builds,file.path(W,'rendered_layers.json'),pretty=TRUE,digits=17,na='null')
write_json(list(width_mm=165.9,height_mm=140,limits=lapply(configs,function(c)c$limits),ylim=c(-.6,7.6),primary_fill='#DFEDF0',scenario_fill='#F3DFE4',font=font_family,regular_pt=7.2,axes_pt=8,tag_pt=10,no_estimation=TRUE),file.path(W,'plot_settings.json'),pretty=TRUE,digits=17)
