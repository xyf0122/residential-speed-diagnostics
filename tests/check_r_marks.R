suppressPackageStartupMessages(library(jsonlite))
a<-commandArgs(trailingOnly=TRUE);D<-a[1];O<-a[2]
eq<-function(x,y)stopifnot(isTRUE(all.equal(as.numeric(x),as.numeric(y),tolerance=1e-12,check.attributes=FALSE)))
j<-function(n,f)fromJSON(file.path(O,paste0('figure',n),f),simplifyVector=TRUE)
d<-read.csv(file.path(D,'components.csv'));b<-j('6','rendered_layers.json');an<-j('6','table_annotations.json')
lims<-list(c(-.04,1.04),c(-.12,3.05),c(-.07,1.75),c(-.04,1.04))
for(i in 1:4){k<-letters[i];dd<-d[d$panel==k,];tx<-function(x)10+(x-lims[[i]][1])/diff(lims[[i]])*39
 eq(an[[k]]$estimate,dd$estimate);eq(an[[k]]$lower,dd$lower);eq(an[[k]]$upper,dd$upper)
 ci<-dd[!is.na(dd$lower),];pt<-dd[!is.na(dd$estimate),]
 eq(b[[k]][[5]]$xmin,tx(ci$lower));eq(b[[k]][[5]]$xmax,tx(ci$upper));eq(b[[k]][[5]]$y,ci$y)
 eq(b[[k]][[6]]$x,tx(pt$estimate));eq(b[[k]][[6]]$y,pt$y)
}
d<-read.csv(file.path(D,'roughness.csv'));b<-j('7','rendered_layers.json');ci<-d[!is.na(d$E_lower),]
eq(b$a[[1]]$xmin,ci$E_lower);eq(b$a[[1]]$xmax,ci$E_upper);eq(b$a[[1]]$y,ci$J)
eq(b$a[[2]]$ymin,ci$J_lower);eq(b$a[[2]]$ymax,ci$J_upper);eq(b$a[[2]]$x,ci$E)
eq(b$a[[4]]$x,d$E);eq(b$a[[4]]$y,d$J)
g<-j('7','gradient_cells.json');eq(g$value,c(d$G_lower,d$G,d$G_upper));stopifnot(identical(g$rid,rep(d$rid,3)))
q<-j('7','quantile_nodes.json');eq(q$value,c(d$L_lower,d$L,d$L_upper));stopifnot(identical(q$rid,rep(d$rid,3)))
p<-j('7','count_labels.json');eq(p$count,c(d$field_tracks,d$accepted_fit));eq(b$d[[1]]$xmax,p$count);eq(b$d[[1]]$xmin,rep(0,nrow(p)))
eq(b$c[[3]]$y,q$value);eq(b$c[[3]]$x,q$x)
d<-read.csv(file.path(D,'scenario.csv'));b<-j('B1','rendered_layers.json')
for(k in letters[1:4]){p<-d[d$panel==k & d$spec=='primary',];s<-d[d$panel==k & d$spec=='scenario',];eq(b[[k]][[1]]$x,p$x);eq(b[[k]][[1]]$xend,s$x);eq(b[[k]][[1]]$y,p$y);eq(b[[k]][[2]]$x,p$x);eq(b[[k]][[3]]$x,s$x)}
cat('PASS: all Figure 6 estimates/intervals; Figure 7 E/J intervals, G cells, span nodes and population bars; all 64 B.1 endpoints.\n')
