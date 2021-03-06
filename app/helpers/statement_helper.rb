module StatementHelper
  def self.included(base)
    base.instance_eval do
      alias_method :proposal_path, :proposal_url
      alias_method :new_proposal_path, :new_proposal_url
      alias_method :new_translation_proposal_path, :new_translation_proposal_url

      alias_method :improvement_proposal_path, :improvement_proposal_url
      alias_method :new_improvement_proposal_path, :new_improvement_proposal_url
      alias_method :new_translation_improvement_proposal_path, :new_translation_improvement_proposal_url
    end
  end

  ##
  ## URLS
  ##


  def new_child_statement_url(parent, type)
    case type.downcase
    when 'question'
      new_question_url(parent)
    when 'proposal'
      new_proposal_url(parent)
    when 'improvement_proposal'
      new_improvement_proposal_url(parent)
    when 'pro_argument'
      new_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  def edit_statement_path(statement)
    case statement_class_dom_id(statement).downcase
    when 'question'
      edit_question_path(statement)
    when 'proposal'
      edit_proposal_path(statement)
    when 'improvement_proposal'
      edit_improvement_proposal_path(statement)
    else
      raise ArgumentError.new("Unhandled type: #{statement_dom_id(statement).downcase}")
    end
  end

  def new_translation_url (parent, type)
    case type.downcase
    when 'question'
      new_translation_question_url(parent)
    when 'proposal'
      new_translation_proposal_url(parent)
    when 'improvement_proposal'
      new_translation_improvement_proposal_url(parent)
    when 'pro_argument'
      new_translation_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  def create_translation_url (parent, type)
    case type.downcase
    when 'question'
      create_translation_question_url(parent)
    when 'proposal'
      create_translation_proposal_url(parent)
    when 'improvement_proposal'
      create_translation_improvement_proposal_url(parent)
    when 'pro_argument'
      create_translation_pro_argument_proposal_url(parent)
    else
      raise ArgumentError.new("Unhandled type: #{type.downcase}")
    end
  end

  # returns the path to a statement, according to its type
  def statement_path(statement)
    statement = StatementNode.find(statement) if statement.kind_of?(Integer)
    case statement_class_dom_id(statement).downcase
    when 'question'
      question_url(statement)
    when 'proposal'
      proposal_url(statement)
    when 'improvement_proposal'
      improvement_proposal_url(statement)
    else
      raise ArgumentError.new("Unhandled type: #{statement_dom_id(statement).downcase}")
    end
  end

  ## Proposal

  def proposal_url(proposal)
    question_proposal_url(proposal.parent,proposal)
  end

  def new_proposal_url(parent)
    new_question_proposal_url(parent)
  end

  def edit_proposal_url(proposal)
    edit_question_proposal_url(proposal.parent, proposal)
  end

  def edit_proposal_path(proposal)
    edit_question_proposal_path(proposal.parent, proposal)
  end

  def new_translation_proposal_url(proposal)
    new_translation_question_proposal_url(proposal.parent, proposal)
  end

  def new_translation_proposal_path(proposal)
    new_translation_question_proposal_path(proposal.parent, proposal)
  end

  def create_translation_proposal_url(proposal)
    create_translation_question_proposal_url(proposal.parent, proposal)
  end

  def create_translation_proposal_path(proposal)
    create_translation_question_proposal_path(proposal.parent, proposal)
  end

  ## ImprovementProposal

  def improvement_proposal_url(proposal)
    question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def new_improvement_proposal_url(parent)
    raise ArgumentError.new("Expected `parent' to be a Proposal (is: #{parent})") unless parent.kind_of?(Proposal)
    raise ArgumentError.new("Expected `parent.parent' to be a Question (is: #{parent.parent})") unless parent.parent.kind_of?(Question)
    new_question_proposal_improvement_proposal_url(parent.parent, parent)
  end

  def edit_improvement_proposal_url(proposal)
    edit_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def edit_improvement_proposal_path(proposal)
    edit_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  def new_translation_improvement_proposal_url(proposal)
    new_translation_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def new_translation_improvement_proposal_path(proposal)
    new_translation_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  def create_translation_improvement_proposal_url(proposal)
    create_translation_question_proposal_improvement_proposal_url(proposal.root, proposal.parent, proposal)
  end

  def create_translation_improvement_proposal_path(proposal)
    create_translation_question_proposal_improvement_proposal_path(proposal.root, proposal.parent, proposal)
  end

  ## ProArgument

  # def new_pro_argument_proposal_url(parent)
  #   raise ArgumentError.new("Expected `parent' to be a Proposal (is: #{parent})") unless parent.kind_of?(Proposal)
  #   raise ArgumentError.new("Expected `parent.parent' to be a Question (is: #{parent.parent})") unless parent.parent.kind_of?(Question)
  #   new_question_proposal_pro_argument_url(parent.parent, parent)
  # end

  ##
  ## LINKS
  ##

  # edited: i18n without interpolation, because of language diffs.
  def create_children_statement_link(statement, css_class = "", lan_tag = "")
    return unless statement.class.expected_children.any?
    type = statement_class_dom_id(statement.class.expected_children.first)
    link_to(I18n.t(lan_tag.blank? ? "discuss.statements.create_#{type}_link" : "discuss.statements.#{lan_tag}"),
            new_child_statement_url(statement, type),
            :id => "create_#{type.underscore}_link",
            :class => "ajax #{css_class} text_button #{create_statement_button_class(type)} ttLink no_border",
            :title => I18n.t("discuss.tooltips.create_#{type.underscore}"))
  end

  def create_translate_statement_link(statement, css_class = "")
     type = statement_class_dom_id(statement)
     link_to I18n.t('discuss.translation_request'),
              new_translation_url(statement, type),
              :class => "ajax translation_link #{css_class}"
  end

  # this classname is needed to display the right icon next to the link
  def create_statement_button_class(type)
    "create_#{type}_button"
  end

  def create_question_link_for(category)
    return unless current_user && current_user.has_role?(:editor)
    link_to(I18n.t("discuss.statements.create_question_link",
            :type => Question.display_name), new_question_url(:category => category.value),
            :class=>'ajax text_button create_question_button ttLink no_border',
            :title => I18n.t("discuss.tooltips.create_question"))
  end

  def edit_statement_link(statement)
    link_to(I18n.t('application.general.edit'), edit_statement_path(statement),
            :class => 'ajax header_button text_button edit_button edit_statement_button') if current_user && current_user.may_edit?(statement)
  end

  # Returns the block heading for the children of the given statement
  def children_box_title(statement)
    type = statement_class_dom_id(statement.class.expected_children.first)
    I18n.t("discuss.statements.headings.#{type}")
  end

  # Returns the block heading for entering a new child for the given statement
  def children_new_box_title(statement)
    type = statement_class_dom_id(statement)
    I18n.t("discuss.statements.new.#{type}")
  end


  ##
  ## CONVENIENCE and UI
  ##

  # returns the right icon for a statement, determined from statement class and given size
  def statement_icon(statement, size = :medium)
    # remove me to have different sizes again
    image_tag("page/discuss/#{statement_class_dom_id(statement)}_#{size.to_s}.png")
  end

  # inserts a status bar based on the support ratio  value
  # (support ratio is the calculated ratio for a statement, representing and visualizing the agreement a statement has found within the community)
  def supporter_ratio_bar(statement,context=nil)
    if statement.supporter_count < 2
      tooltip = I18n.t('discuss.tooltips.echo_indicator.one', :supporter_count => statement.supporter_count)
    else
      tooltip = I18n.t('discuss.tooltips.echo_indicator.many', :supporter_count => statement.supporter_count)
    end
    if statement.ratio > 1
      val = "<span class='echo_indicator ttLink' title='#{tooltip}' alt='#{statement.ratio}'></span>"
    else
      val = "<span class='no_echo_indicator ttLink' title='#{tooltip}'></span>"
    end
  end


  # TODO: instead of adding an image tag, we should use css classes here, like (almost) everywhere else
  # TODO: find out why statement.question? works, but not statement.parent.question? or deprecate statement.question?
  # possible answer: method is private - invoking .send :question? on parent does the trick!

  ##
  ## Statement Context (where am i within the statement stack?)
  ##


  # DEPRICATED, user statement_context_link instead
  def statement_context_line(statement)
    link = link_to(statement_icon(statement, :small)+statement.title, url_for(statement), :class => 'ajax')
    link << supporter_ratio_bar(statement,'context') unless statement.class.name == 'Question'
    return link
  end

  # Returns the context menu link for this statement.
  def statement_context_link(statement, language_keys, action = 'read', last_statement = false)

    link = link_to(statement.translated_document(language_keys).title, url_for(statement),
                   :class => "ajax no_border statement_link #{statement.class.name.underscore}_link ttLink",
                   :title => I18n.t("discuss.tooltips.#{action}_#{statement.class.name.underscore}"))
    if statement.class.name == 'Question'
      link << echo_label unless last_statement
    else
      link << supporter_ratio_bar(statement,'context')
    end
    return link
  end

  # Creates a label to explain the echo/supporter count indicators
  def echo_label(context=nil)
    val = "<span class='echo_label'>#{I18n.t('discuss.statements.label')}</span>"
  end

  ##
  ## Navigation within statements
  ##

  # Insert prev/next buttons for the current statement.
  def prev_next_buttons(statement)
    type = statement.class.to_s.underscore
    key = ("current_" + type).to_sym
    if session[key].present? and session[key].include?(statement.id)
      index = session[key].index(statement.id)
      buttons = if session[key].length == 1
                  statement_tag(:prev, type, true)
                elsif index == 0
                  #statement_tag(:prev, type, true)
                  statement_button(session[key][session[key].length-1], statement_tag(:prev, type), :rel => 'prev')
                else
                  statement_button(session[key][index-1], statement_tag(:prev, type), :rel => 'prev')
                end
      buttons << if session[key].length == 1
                   statement_tag(:next, type, true)
                 elsif index == session[key].length-1
                   #statement_tag(:next, type, true)
                   statement_button(session[key][0], statement_tag(:next, type), :rel => 'next')
                 else
                   statement_button(session[key][index+1], statement_tag(:next, type), :rel => 'next')
                 end
    end
  end

  def statement_tag(direction, class_identifier, disabled=false)
    if !disabled
      content_tag(:span, '&nbsp;', :class => "#{direction}_stmt ttLink no_border",
                  :title => I18n.t("discuss.tooltips.#{direction}_#{class_identifier}"))
    else
      content_tag(:span, '&nbsp;', :class => "#{direction}_stmt disabled")
    end
  end

  # Insert a button that links to the previous statement
  # TODO AR from the helper stinks, but who knows a better way to get the right url?
  # maybe one could code some statement.url method..?
  def statement_button(id, title, options={})
    stmt = StatementNode.find(id)
    options[:class] ||= ''
    options[:class] += ' ajax'
    return link_to(title, url_for(stmt), options)
  end

  ##
  ## DOM-ID Helpers
  ##

  # returns the statement class dom identifier (used to identifiy dom objects, e.g. for javascript)
  def statement_class_dom_id(statement)
    if statement.kind_of?(Symbol)
      statement_class = statement.to_s.constantize
     elsif statement.kind_of?(StatementNode)
      statement_class = statement.class
    end
    statement_class.name.underscore.downcase
  end

  # returns the dom identifier for a particular statement
  # consisting out of the statement class dom identifier, and the statements id
  def statement_dom_id(statement)
    "#{statement_class_dom_id(statement)}_#{statement.id}"
  end

end
