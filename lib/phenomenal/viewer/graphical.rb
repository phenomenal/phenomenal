# Define the way to generate a representation of the system
# using the graphical library graphviz
class Phenomenal::Viewer::Graphical
  begin
    require "graphviz"
    @@graphviz=true
  rescue LoadError
    @@graphviz=false
  end  
  
  attr_reader :manager, :rmanager
  attr_accessor :main_graph, :feature_nodes, :r_feature_nodes, :context_nodes, :destination_file
  
  def initialize(destination_file)
    if !@@graphviz
      Phenomenal::Logger.instance.error(
        "The 'ruby-graphviz' gem isn't available. Please install it to generate graphic visualisations\n"+
        " Otherwise use the text version: phen_textual_view"
      )
    end
    
    @manager=Phenomenal::Manager.instance
    @rmanager=Phenomenal::RelationshipsManager.instance
    @destination_file=destination_file
    @main_graph=nil
    @feature_nodes={}
    @r_feature_nodes={}
    @context_nodes={}
  end
  
  def generate()
    set_options()
    # Add nodes to the graph
    self.manager.contexts.each do |key,context|
      if !feature_nodes.include?(context) && !context_nodes.include?(context)
        add_node_for(context)
      end
    end
    # Create a relationship links
    self.manager.contexts.each do |key,context|
      add_edges_for(context)
    end
    self.main_graph.output(:png => destination_file)
  end
  
  private
  def set_options
    # Create main graph
    self.main_graph = GraphViz::new("")
    # Default options
    self.main_graph[:compound] = "true"
    self.main_graph.edge[:lhead] = ""
    self.main_graph.edge[:ltail] = ""
    self.main_graph.edge[:fontsize] = 10.0
  end
  
  def add_edges_for(context)
    if context.is_a?(Phenomenal::Feature)
      context.relationships.each do |relationship|
        # Get source and destionation node
        ltail=""
        lhead=""
        relationship.refresh
        
        source_node,ltail = node(relationship.source)
        target_node,lhead = node(relationship.target)
        
        # Get graph container
        graph = graph_container(relationship)
        
        # Add edge
        edge=graph.add_edges(source_node,target_node,:ltail=>ltail,:lhead=>lhead)   
        # Define edge label
        if context!=manager.default_context
          edge[:label]=context.to_s
         end
        # Define edge color
        if rmanager.relationships.include?(relationship)
          edge[:color]="red"
        end
        # Define arrow type
        set_arrow_type(edge,relationship)
      end
    end
  end
  
  def node(feature)
    if feature_nodes.include?(feature)
      [r_feature_nodes[feature],"cluster_#{feature.to_s}"]
    else 
      [context_nodes[feature],""]
    end
  end
  
  def graph_container(relationship)
    s_parent_feature=relationship.source.parent_feature
    t_parent_feature=relationship.target.parent_feature
    if s_parent_feature==t_parent_feature && s_parent_feature!=manager.default_context
      feature_nodes[relationship.source.parent_feature]
    else
      main_graph
    end
  end
  
  def set_arrow_type(edge,relationship)
    # Define arrow type
    if relationship.is_a?(Phenomenal::Implication)
      edge[:arrowhead]="normal"
    elsif relationship.is_a?(Phenomenal::Suggestion)
      edge[:arrowhead]="empty"
    elsif relationship.is_a?(Phenomenal::Requirement)
      edge[:arrowhead]="inv"
    else
      Phenomenal::Logger.instance.error(
        "This relationship hasn't been defined yet in the graphical viewer"
      )
    end
  end
  
  def add_node_for(context)
    # The default context is the first to be added to the main graph
    if feature_nodes[context.parent_feature].nil? && context==manager.default_context 
      current_graph=main_graph
    # Always add the parent_feature before the contexts inside
    elsif feature_nodes[context.parent_feature].nil?
      add_node_for(context.parent_feature)
    else
      current_graph=feature_nodes[context.parent_feature]
    end
    # Add node
    if context.is_a?(Phenomenal::Feature)
      node = add_node_for_feature(context,current_graph)
    else
      node = add_node_for_context(context,current_graph)
    end
    # Define node color
    if context.active?
      node[:color]="red"
    else
      node[:color]="black"
    end
  end
  
  def add_node_for_feature(feature,current_graph)
    node=current_graph.add_graph("cluster_#{feature.to_s}")
    node[:label]="#{feature.to_s}"
    # Add hidden node for feature relationship
    fr=node.add_nodes("#{feature.to_s}_relationship")
    fr[:style]="invis"
    fr[:height]=0.02
    fr[:width]=0.02
    fr[:fixedsize]=true
    self.feature_nodes[feature]=node
    self.r_feature_nodes[feature]=fr
    node
  end
  
  def add_node_for_context(context,current_graph)
    node=current_graph.add_nodes(context.to_s) 
    self.context_nodes[context]=node
    node
  end
end
