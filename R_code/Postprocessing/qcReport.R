args = commandArgs(trailingOnly = T)

dat = read.csv(args[1], stringsAsFactors = F)

dat$qcPass = !is.na(dat$score) & dat$precision %in% c('range','street') & 
  dat$score > 0.5

cat('\n',sum(dat$qcPass), ' addresses satisfactorily matched\n',sep='')
cat(sum(1-dat$qcPass), 'addresses flagged with poor quality matches\n')

write.csv(dat,args[1])

