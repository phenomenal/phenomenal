set title ""
set ylabel "Seconds"
set xlabel "Number of adapted methods"
#set nokey
#set key right center title 'Legend' box 3
#set xrange [ 100 : 10000 ]
#set yrange [ 0 : 0.5 ]
#set logscale x
#set logscale y
set terminal  postscript eps color "Times-Roman" 16
set output "method_count.eps"
plot "method.dat" using 1:4 with lines linewidth 3  title "Method"
