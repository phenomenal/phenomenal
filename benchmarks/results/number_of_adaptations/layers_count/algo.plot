set title ""
set ylabel "Seconds"
set xlabel "Number of activated contexts"
#set nokey
#set key right center title 'Legend' box 3
#set xrange [ 100 : 10000 ]
#set yrange [ 0 : 0.5 ]
#set logscale x
#set logscale y
set terminal  postscript eps color "Times-Roman" 16
set output "layers_count.eps"
plot "same_method.dat" using 1:4 with lines linewidth 3  title "Same method", "different_method.dat" using 1:4 with lines linewidth 3  title "Different method"
