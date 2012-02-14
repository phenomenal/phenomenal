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
        "The 'ruby-graphviz' gem isn't available. Please install it to generate graphic visualitations\n"+
        " Otherwise use the text version"
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
    # Create main graph
    self.main_graph = GraphViz::new("")
    # Default options
    self.main_graph[:compound] = "true"
    self.main_graph.edge[:lhead] = ""
    self.main_graph.edge[:ltail] = ""
    self.main_graph.edge[:fontsize]=10.0
    # Add nodes to the graph
    self.manager.contexts.each do |key,context|
      if not self.feature_nodes.include?(context) and not @context_nodes.include?(context)
        add_node_for(context)
      end
    end
    # Create a relationship links
    self.manager.contexts.each do |key,context|
      add_edges_for(context)
    end
    self.main_graph.output( :png => self.destination_file )
  end
  
  private
  def add_edges_for(context)
    if context.is_a?(Phenomenal::Feature)
      context.relationships.each do |relationship|
        # Get source and destionation node
        ltail=""
        lhead=""
        relationship.refresh
        if self.feature_nodes.include?(relationship.source)
          source_node=self.r_feature_nodes[relationship.source]
          ltail="cluster_#{relationship.source.to_s}"
        else 
          source_node=self.context_nodes[relationship.source]
        end
        if self.feature_nodes.include?(relationship.target)
          target_node=self.r_feature_nodes[relationship.target]
          lhead="cluster_#{relationship.target.to_s}"
        else
          target_node=self.context_nodes[relationship.target]
        end
        # Define graph container
        s_parent_feature=relationship.source.parent_feature
        t_parent_feature=relationship.target.parent_feature
        if s_parent_feature==t_parent_feature && s_parent_feature!=self.manager.default_context
          graph=self.feature_nodes[relationship.source.parent_feature]
        else
          graph=self.main_graph
        end
        # Add edge
        edge=graph.add_edges(source_node,target_node,:ltail=>ltail,:lhead=>lhead)   
        # Define edge label
        if context!=self.manager.default_context
          edge[:label]=context.to_s
         end
        # Define edge color
        if self.rmanager.relationships.include?(relationship)
          edge[:color]="red"
        end
        # Define arrow type
        if relationship.is_a?(Phenomenal::Implication)
          edge[:arrowhead]="normal"
        elsif relationship.is_a?(Phenomenal::Suggestion)
          edge[:arrowhead]="empty"
        elsif relationship.is_a?(Phenomenal::Requirement)
          edge[:arrowhead]="inv"
        else
        end
      end
    end
  end
  
  def add_node_for(context)
    # The default context is the first to be added to the main graph
    if self.feature_nodes[context.parent_feature].nil? and context==self.manager.default_context 
      current_graph=self.main_graph
    # Always add the parent_feature before the contexts inside
    elsif @feature_nodes[context.parent_feature].nil?
      self.add_node_for(context.parent_feature)
    else
      current_graph=self.feature_nodes[context.parent_feature]
    end
    # Add node
    if context.is_a?(Phenomenal::Feature)
      node=current_graph.add_graph("cluster_#{context.to_s}")
      node[:label]="#{context.to_s}"
      # Add hidden node for feature relationship
      fr=node.add_nodes("#{context.to_s}_relationship")
      fr[:style]="invis"
      fr[:height]=0.02
      fr[:width]=0.02
      fr[:fixedsize]=true
      self.feature_nodes[context]=node
      self.r_feature_nodes[context]=fr
    else
      node=current_graph.add_nodes(context.to_s) 
      self.context_nodes[context]=node
    end
    # Define node color
    if context.active?
      node[:color]="red"
    end
  end
end
