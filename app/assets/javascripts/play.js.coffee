assert = (exp) ->
  throw 'Runtime error' unless exp

p = (exp) ->
  console.log(exp)

ACE = 0
KING = 12

set_position = (element, left, top) ->
  element.css({ position: 'absolute', left: "#{left}px", top: "#{top}px"})

set_stack_type = (element, stack_type) ->
  for s in ['fanned_down', 'fanned_right', 'stacked']
    if s == stack_type
      element.addClass s
    else
      element.removeClass s

class Card
  @next_id = 0

  constructor: (@rank, @suit, @upturned) ->
    assert @rank? and @suit? and ACE <= rank <= KING and 0 <= suit <= 3 and @upturned?
    @id = "card_#{Card.next_id++}"
    @element = $("<div class=\"card\" id=\"#{@id}\"></div>")
    @update_element()

  upturn: ->
    @upturned = true
    @update_element()
    this

  downturn: ->
    @upturned = false
    @update_element()
    this

  update_element: ->
    if @upturned
      @element.html("<div class=\"face\">#{@id} #{'A23456789TJQK'[@rank] + '♣♠♥♦'[@suit]}</div>")
    else
      @element.html("<div class=\"back\">#{@id}</div>")

class GameState
  constructor: (@canvas_div) ->
    @stock = _.shuffle(_.flatten(new Card(r, s, false) for r in [ACE..KING] for s in [0..3]))
    @downturned_tableaux = [[], [], [], [], [], [], []]
    @upturned_tableaux = [[], [], [], [], [], [], []]
    @foundations = [[], [], [], []]
    @waste = []
    for i in [0...7]
      for j in [i+1...7]
        @downturned_tableaux[j].push(@stock.pop())
      c = @stock.pop()
      c.upturn()
      @upturned_tableaux[i].push(c)
    @foundation_blank_html = '<div class="card"><div class="blank"></div></div>'

  turn: ->
    for i in [0...3]
      if @stock.length
        c = @stock.pop()
        c.upturn()
        @waste.push c
    @render()

  redeal: ->
    while @waste.length
      @stock.push @waste.pop().downturn()
    @render()

  render: ->
    z_index = 1
    # Tableaux
    for i in [0...@downturned_tableaux.length]
      append_to = $("#tableau_#{i}_base")
      # Downturned
      for c in @downturned_tableaux[i]
        e = c.element
        e.css('z-index', z_index++)
        set_stack_type(e, 'fanned_down')
        append_to.append(e)
        append_to = e
      # Upturned
      for c in @upturned_tableaux[i]
        e = c.element
        e.css('z-index', z_index++)
        set_stack_type(e, 'fanned_down')
        append_to.append(e)
        append_to = e
    # Stock
    append_to = $('#stock_base')
    if not @stock.length
      if @waste.length then $('#redeal_image').show() else $('#redeal_image').hide()
      if not @waste.length then $('#exhausted_image').show() else $('#exhausted_image').hide()
    for c in @stock
      append_to.append(c.element)
      set_stack_type(c.element, 'stacked')
      c.element.css('z-index', z_index++)
      append_to = c.element
    # Waste
    append_to = $('#waste_base')
    for c, index in @waste
      set_stack_type(c.element, if index < @waste.length - 2 then 'stacked' else 'fanned_right')
      append_to.append(c.element)
      append_to = c.element
    # Foundations
    for i in [0...@foundations.length]
      0
      # TODO: render cards

    # Register events
    @canvas_div.off('.solitaire', '**')
    if @stock.length
      @canvas_div.on 'click.solitaire', "##{@stock[@stock.length-1].id}", =>
        @turn()
    else if @waste.length
      @canvas_div.on 'click.solitaire', "#redeal_image", =>
        @redeal()

# Throwing this into window can't be right?
window.solitaire_main = (canvas_div) ->
  state = new GameState(canvas_div)
  state.render()
