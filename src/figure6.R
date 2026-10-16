# Draw saved aggregate summaries; no estimation or resampling.
suppressPackageStartupMessages({library(ggplot2);library(patchwork);library(grid);library(jsonlite)})
args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2)
D<-normalizePath(args[1]);W<-args[2];dir.create(W,recursive=TRUE,showWarnings=FALSE)
font_family<-Sys.getenv("AAP_FONT",if(capabilities("aqua")) "Arial" else "Helvetica")
do.call(grDevices::pdfFonts,setNames(list(grDevices::pdfFonts()$Helvetica),font_family))
grDevices::pdf(file=NULL,family=font_family)
d<-read.csv(file.path(D,'components.csv'),stringsAsFactors=FALSE)
cols<-c(a='#4B7FA3',b='#8B729A',c='#298A83',d='#B18A43')
titles<-c('Exceedance extent','Conditional severity','Average excess','Self-enforcement index')
xlabs<-list(expression(italic(p)),expression(italic(m)~'(conditional mph)'),expression(italic(A)~'(conditional mph)'),expression(italic(E)))
xlims<-list(c(-.04,1.04),c(-.12,3.05),c(-.07,1.75),c(-.04,1.04))
breaks<-list(c(0,.5,1),c(0,1,2,3),c(0,.5,1,1.5),c(0,.5,1))
# Coordinates use 100 layout units, not scientific units. Each metric maps only into x=10..49.
xplot<-c(10,49);tablex<-c(64,81,98);plots<-list();builds<-list();annotations<-list();transforms<-list()
for(i in 1:4){
 key<-letters[i];cc<-cols[[key]];dd<-d[d$panel==key,];lims<-xlims[[i]]
 tx<-function(x) xplot[1]+(x-lims[1])/diff(lims)*diff(xplot)
 dd$px<-tx(dd$estimate);dd$pl<-tx(dd$lower);dd$pu<-tx(dd$upper)
 digits<-if(i %in% c(1,4))3 else 2
 fmt<-function(x)ifelse(is.na(x),'—',sprintf(paste0('%.',digits,'f'),x))
 dd$estimate_text<-fmt(dd$estimate);dd$estimate_text[is.na(dd$estimate)]<-'NA'
 dd$lower_text<-fmt(dd$lower);dd$upper_text<-fmt(dd$upper)
 pt<-dd[!is.na(dd$estimate),];pt$fillcolor<-ifelse(pt$status=='primary',cc,'white')
 ci<-dd[!is.na(dd$lower),]
 band<-data.frame(y=c(7,5,3,1));tick<-data.frame(x=tx(breaks[[i]]),label=format(breaks[[i]],trim=TRUE,scientific=FALSE))
 p<-ggplot()+
  geom_rect(data=band,aes(xmin=0,xmax=100,ymin=y-.5,ymax=y+.5),fill='#F2F3F4',colour=NA)+
  geom_segment(aes(x=0,xend=100,y=9.25,yend=9.25),linewidth=.8/ggplot2::.pt,colour='#333333')+
  geom_segment(aes(x=0,xend=100,y=7.65,yend=7.65),linewidth=.8/ggplot2::.pt,colour='#333333')+
  geom_segment(aes(x=0,xend=100,y=-.6,yend=-.6),linewidth=.8/ggplot2::.pt,colour='#333333')+
  geom_errorbar(data=ci,aes(xmin=pl,xmax=pu,y=y),orientation='y',width=.16,linewidth=.8/ggplot2::.pt,colour=cc)+
  geom_point(data=pt,aes(x=px,y=y,shape=status,fill=fillcolor),size=1.6,stroke=.4,colour=cc)+
  scale_shape_manual(values=c(primary=21,descriptive=23,withheld=21),guide='none')+scale_fill_identity()+
  geom_text(data=dd,aes(x=1,y=y,label=rid),hjust=0,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
  geom_text(data=dd,aes(x=tablex[1],y=y,label=estimate_text),hjust=1,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
  geom_text(data=dd,aes(x=tablex[2],y=y,label=lower_text,vjust=ifelse(lower_text=="—",.36,.5)),hjust=1,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
  geom_text(data=dd,aes(x=tablex[3],y=y,label=upper_text,vjust=ifelse(upper_text=="—",.36,.5)),hjust=1,family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
  annotate('text',x=3.5,y=8.15,label='Acq.',family=font_family,size=7.2/ggplot2::.pt)+
  annotate('text',x=29.5,y=8.15,label='Estimate and interval',family=font_family,size=7.2/ggplot2::.pt)+
  annotate('text',x=59,y=8.15,label='Estimate',family=font_family,size=7.2/ggplot2::.pt)+
  annotate('text',x=c(77,94),y=8.15,label=c('Lower','Upper'),family=font_family,size=7.2/ggplot2::.pt)+
  annotate('text',x=85.5,y=8.85,label='95% interval',family=font_family,size=7.2/ggplot2::.pt)+
  geom_segment(data=tick,aes(x=x,xend=x,y=-.6,yend=-.82),linewidth=.8/ggplot2::.pt,colour='#333333')+
  geom_text(data=tick,aes(x=x,y=-1.25,label=label),family=font_family,size=7.2/ggplot2::.pt,colour='#1F1F1F')+
  scale_x_continuous(limits=c(0,100),expand=expansion(mult=0))+
  scale_y_continuous(limits=c(-2.5,9.5),expand=expansion(mult=0))+
  labs(title=titles[i])+theme_void(base_family=font_family,base_size=7.2)+
  theme(plot.title=element_text(size=8,face='plain',colour='#1F1F1F',margin=margin(b=7)),plot.title.position='plot',plot.margin=margin(4,6,7,5),
        plot.tag=element_text(size=10,face='bold',colour='black',hjust=0,vjust=1),plot.tag.position='topleft',plot.tag.location='margin',legend.position='none')
 # Plotmath axis labels are kept separate from the numerical table.
 xlabel<-c('italic(p)','italic(m)~"(conditional mph)"','italic(A)~"(conditional mph)"','italic(E)')[i]
 p<-p+annotate('text',x=29.5,y=-2.12,label=xlabel,parse=TRUE,family=font_family,size=8/ggplot2::.pt)
 if(i==2)p<-p+annotate('text',x=tx(.12),y=4,label='NA',family=font_family,size=7.2/ggplot2::.pt,hjust=0,colour='#666666')
 plots[[i]]<-p;builds[[key]]<-lapply(ggplot_build(p)$data,as.data.frame);annotations[[key]]<-dd
 transforms[[key]]<-list(xlim=lims,xplot=xplot,table_rights=tablex,ylim=c(-2.5,9.5),layout_xlim=c(0,100),rounding_digits=digits)
}
keyg<-grobTree(pointsGrob(x=unit(c(.07,.34,.70),'npc'),y=unit(rep(.78,3),'npc'),pch=c(21,23,21),size=unit(1.6,'mm'),gp=gpar(col='#333333',fill=c('#333333','white','white'),lwd=.6)),
 textGrob(c('Primary estimate','r19: 4-day descriptive','Severity interval withheld'),x=unit(c(.09,.36,.72),'npc'),y=unit(rep(.78,3),'npc'),just='left',gp=gpar(fontfamily=font_family,fontsize=7.2,col='#1F1F1F')),
 textGrob('Table values use the units of each panel; — indicates no reported interval.',x=.5,y=.25,gp=gpar(fontfamily=font_family,fontsize=7.2,col='#555555')))
layout<-wrap_plots(plots,ncol=2,byrow=TRUE)
final<-layout/wrap_elements(full=keyg,ignore_tag=TRUE)+plot_layout(heights=c(1,.075))+plot_annotation(tag_levels='a',theme=theme(plot.background=element_rect(fill='white',colour=NA)))
pdf_device<-function(filename,width,height,...)if(capabilities("aqua")) grDevices::quartz(file=filename,type="pdf",width=width,height=height,...) else grDevices::pdf(file=filename,width=width,height=height,encoding="WinAnsi.enc",useDingbats=FALSE,...)
ggsave(file.path(W,'Figure6.pdf'),final,device=pdf_device,width=165.9,height=145,units='mm',family=font_family,bg='white')
write_json(builds,file.path(W,'rendered_layers.json'),pretty=TRUE,digits=17,na='null')
write_json(annotations,file.path(W,'table_annotations.json'),pretty=TRUE,digits=17,na='null')
write_json(list(width_mm=165.9,height_mm=145,colors=cols,labels_pt=7.2,axis_labels_pt=8,tags='patchwork bold black a-d, 10 pt',transforms=transforms,no_estimation=TRUE),file.path(W,'plot_settings.json'),pretty=TRUE)
