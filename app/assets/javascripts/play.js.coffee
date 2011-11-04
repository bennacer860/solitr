assert = (exp) ->
  throw 'Runtime error' unless exp

p = (exp) ->
  console.log(exp)

ACE = 0
KING = 12

set_position = (element, left, top) ->
  element.css({ position: 'absolute', left: "#{left}px", top: "#{top}px"})

set_stacked = (element) ->
  element.removeClass('fanned')
  element.addClass('stacked')
set_fanned = (element) ->
  element.removeClass('stacked')
  element.addClass('fanned')

class Card
  constructor: (@rank, @suit, @upturned) ->
    assert @rank? and @suit? and ACE <= rank <= KING and 0 <= suit <= 3 and @upturned?
    @element = $("<div class=\"card\"></div>")
    @update_element()

  upturn: ->
    @upturned = true
    @update_element()

  update_element: ->
    if @upturned
      @element.html("<div class=\"face\">#{'A23456789TJQK'[@rank] + '♣♠♥♦'[@suit]}</div>")
    else
      @element.html("<div class=\"back\"></div>")

class GameState
  constructor: ->
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

  render: (canvas_div) ->
    z_index = 1
    # Tableaux
    for i in [0...@downturned_tableaux.length]
      append_to = $("#tableau_#{i}_base")
      # Downturned
      for c in @downturned_tableaux[i]
        e = c.element
        e.css('z-index', ++z_index)
        set_fanned(e)
        append_to.append(e)
        append_to = e
      # Upturned
      for c in @upturned_tableaux[i]
        e = c.element
        e.css('z-index', ++z_index)
        set_fanned(e)
        append_to.append(e)
        append_to = e
    # Stock
    append_to = $('#stock_base')
    for c in @stock
      append_to.append(c.element)
      set_stacked(c.element)
      c.element.css('z-index', ++z_index)
      append_to = c.element
    # TODO: waste
    # Foundations
    for i in [0...@foundations.length]
      0
      # TODO: render cards

# Throwing this into window can't be right?
window.solitaire_main = (canvas_div) ->
  state = new GameState
  state.render(canvas_div)
