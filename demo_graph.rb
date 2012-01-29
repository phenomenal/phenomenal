require "graphviz"

graph = GraphViz::new( "G" )

graph["compound"] = "true"
graph.edge["lhead"] = ""
graph.edge["ltail"] = ""

f1 = graph.add_graph( "cluster_f1" )
f1[:label]="feature 1"

f1n = f1.add_nodes("f1n")
f1n[:style]="invis"
f1n[:height]=0.02
f1n[:width]=0.02
f1n[:fixedsize]=true
f1c1 = f1.add_nodes( "f1c1" )
f1c2 = f1.add_nodes( "f1c2" )
f1c3 = f1.add_nodes( "f1c3")
f1.add_edges( f1c1, f1c2 )
f1.add_edges( f1c1, f1c3 )

f2 = graph.add_graph( "cluster_f2" )
f2[:label]="feature 2"

f2n = f2.add_nodes("f2n")
f2n[:style]="invis"
f2n[:height]=0.02
f2n[:width]=0.02
f2n[:fixedsize]=true


f2c1 = f2.add_nodes( "f2c1" )
f2c2 = f2.add_nodes( "f2c2" )
f2.add_edges( f2c1, f2c2 )

c1ext = graph.add_nodes( "c1" )
graph.add_edges(f1c1,c1ext)
graph.add_edges(f2c1,c1ext)
graph.add_edges( f1n,f2n,"ltail" => "cluster_f1", "lhead" => "cluster_f2" )

graph.output( :png => "test.png" )