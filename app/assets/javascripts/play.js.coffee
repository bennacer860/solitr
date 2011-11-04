assert = (exp) ->
  throw 'Runtime error' unless exp

p = (exp) ->
  console.log(exp)

ACE = 0
KING = 12

FIRST_ROW = 20
SECOND_ROW = 250
FIRST_COLUMN = 20
CARD_WIDTH = 120
CARD_HEIGHT = 200
VERTICAL_FANNING_OFFSET = 20
HORIZONTAL_FANNING_OFFSET = 20
COLUMN_OFFSET = CARD_WIDTH + 20

class Card
  @next_id = 0

  constructor: (@rank, @suit, @upturned) ->
    assert @rank? and @suit? and ACE <= rank <= KING and 0 <= suit <= 3 and @upturned?
    @id = "card_#{Card.next_id++}"
    @element = $("<div class=\"card\" id=\"#{@id}\"></div>")
    @update_element()

  update_element: ->
    if @upturned
      @element.html("<div class=\"face\">#{@id} #{'A23456789TJQK'[@rank] + '♣♠♥♦'[@suit]}</div>")
    else
      @element.html("<div class=\"back\">#{@id}</div>")

  render_at: (left, top, upturned, z_index = '') ->
    if @upturned != upturned
      @upturned = upturned
      @update_element()
    @element.css
      position: 'absolute'
      left: "#{left}px"
      top: "#{top}px"
      'z-index': z_index


class GameState
  constructor: (@canvas_div) ->
    @deck = _.flatten(new Card(r, s, false) for r in [ACE..KING] for s in [0..3])
    @stock = _.shuffle(@deck)
    @downturned_tableaux = [[], [], [], [], [], [], []]
    @upturned_tableaux = [[], [], [], [], [], [], []]
    @foundations = [[], [], [], []]
    @waste = []
    for i in [0...7]
      for j in [i+1...7]
        @downturned_tableaux[j].push(@stock.pop())
      @upturned_tableaux[i].push(@stock.pop())
    @foundation_blank_html = '<div class="card"><div class="blank"></div></div>'

  turn: ->
    for i in [0...3]
      if @stock.length
        @waste.push(@stock.pop())
    @render()

  redeal: ->
    while @waste.length
      @stock.push @waste.pop()
    @render()

  render: ->
    for c in @deck
      @canvas_div.append(c.element)
    z_index = 1
    # Tableaux
    for i in [0...@downturned_tableaux.length]
      left = FIRST_COLUMN + COLUMN_OFFSET * i
      top = SECOND_ROW
      for c, index in @downturned_tableaux[i]
        c.render_at(left, top, false, z_index++)
        top += VERTICAL_FANNING_OFFSET
      for c, index in @upturned_tableaux[i]
        c.render_at(left, top, true, z_index++)
        top += VERTICAL_FANNING_OFFSET
    # Stock
    if not @stock.length
      if @waste.length then $('#redeal_image').show() else $('#redeal_image').hide()
      if not @waste.length then $('#exhausted_image').show() else $('#exhausted_image').hide()
    left = FIRST_COLUMN
    top = FIRST_ROW
    for c in @stock
      c.render_at(left, top, false, z_index++)
    # Waste
    left = FIRST_COLUMN + COLUMN_OFFSET
    top = FIRST_ROW
    for c, index in @waste
      c.render_at(left, top, true, z_index++)
      if index >= @waste.length - 3
        left += HORIZONTAL_FANNING_OFFSET
    # Foundations
    left = FIRST_COLUMN + 3 * COLUMN_OFFSET
    top = FIRST_ROW
    for foundation, index in @foundations
      for c in foundation
        c.render_at(left, top, true, z_index++)
      left += COLUMN_OFFSET
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
