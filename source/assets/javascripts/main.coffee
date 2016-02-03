$ ->
  # Custom radio
  $( '.custom-radio' ).append( '<span class="radio-icon"/>' )
  # Load default data into tabs-container for checked items
  $( '#tickers .radio-input[name*="ticker"]:checked' ).each (e) ->
    getLastNews( @ )
  $( '.tab-body.active .radio-input[name*="ticker"]:checked' ).each (e) ->
    getChartData( @ )
    getNews( @ )

  # Bind methods to changes radio
  $( '#tickers .radio-input[name*="ticker"]' ).on 'change', (e) ->
    $(@).parents( '.tab-body' ).find( '.custom-radio' ).removeClass( 'checked' )
    $(@).parent().addClass( 'checked' )
    getLastNews( @ )
    getChartData( @ )
    getNews( @ )

  # Tabs
  $( '.tab' ).on 'click', (e) ->
    e.preventDefault()
    _href = $(@).attr( 'href' )
    $(_href).siblings().removeClass( 'active' ).end().andSelf().addClass( 'active' )
    $(@).siblings().removeClass( 'active' ).end().andSelf().addClass( 'active' )
    setTimeout( ->
      $( '.tab-body.active .radio-input[name*="ticker"]:checked' ).each (e) ->
        getChartData( @ )
        getNews( @ )
    , 500)

  $( '.switch .item' ).on 'click', (e) ->
    e.preventDefault()
    _href = $(@).attr( 'href' )
    $(_href).siblings().removeClass( 'active' ).end().andSelf().addClass( 'active' )
    $(@).siblings().removeClass( 'active' ).end().andSelf().addClass( 'active' )
  # Selectize
  $( 'select' ).selectize()
  # Calculator
  $('.calculator #calc-range-input').on 'change', ->
    val = ($(@).val().match(/([0-9\s]+)( ₽)/)[1].replace(/\s/g, "") * 1).formatMoney(0, '', ' ')
    $(@).val( val )
    $('.calculator #range-value').text( val )

  $('input[name="calc_period"]').on 'change', ->
    value = $('.calculator #calc-range-input').val().match(/([0-9\s]+)( ₽)/)[1].replace(/\s/g, "") * 1
    $( 'input[name="calc_period"]' ).parent().removeClass('active')
    $( @ ).parent().addClass('active')
    $('.calculator #profit').text( calcValue( value) )


getNews = ( elem ) ->
  _ticker = $(elem).val()
  $.getJSON 'news.json?ticker=' + _ticker, ( data ) ->
    _items = []
    $( '#meta-news-container' ).html( '' )
    $.each data['news'], ( key,val ) ->
      _time = $( '<time/>', { 'class': 'date', html: val['datetime'] } )
      _title = $( '<h4/>', { 'class': 'title', html: val['title'] } )
      _content = $( '<div/>', { 'class': 'news-content', html: val['teaser'] } )
      _actions = $( '<div/>', { 'class': 'actions clearfix', html: '<a class="more" href="' + val['url'] + '">Подробнее</a>' } )
      _item = $( '<li/>', { 'class': 'news-item' } )
      _item.append( _time ).append( _title ).append( _content ).append( _actions )
      $( '#meta-news-container' ).append( _item )

getLastNews = ( elem ) ->
  _ticker = $(elem).val()
  _time = $( '<time/>', { 'class': 'date' } )
  _title = $( '<h3/>', { 'class': 'news-title' } )
  _content = $( '<div/>', { 'class': 'news-content' })
  _target = $(elem).data( 'target' )
  $.getJSON 'news.json?ticker=' + _ticker, ( data ) ->
    _time.html( data['news'][0]['datetime'] )
    _title.html( '<a href="' + data['news'][0]['url']  + '">' + data['news'][0]['title'] + '</a>' )
    _content.html( data['news'][0]['teaser'] )
    $( '.news-item', _target ).html('')
    $( '.news-item', _target ).append( _time ).append( _title ).append( _content )

getChartData = ( elem ) ->
  _ticker = $(elem).val()
  $.getJSON 'data.json?ticker=' + _ticker, ( data ) ->
    _context = $( '#graph' )
    _exchange = data['exchange']
    _current_price = data['price']['current']
    _change_pips = data['price']['change_pips']
    _change_perc = data['price']['change_percent']
    _open = data['price']['open']
    _max = data['price']['max']
    _min = data['price']['min']
    _close = data['price']['close']
    _volume = data['price']['volume']
    _ticker = data['ticker']
    _time = data['time']
    _date = data['date']
    _block_title = data['block_title']
    $( '#container-title span' ).html _block_title
    $( '#card-change-pips, #card-change-perc', _context ).removeClass 'up down'
    $( '#data-title', _context ).html _exchange
    $( '#card-current-price', _context ).html _current_price
    $( '#card-change-pips', _context ).html(_change_pips).addClass( 'up' )
    $( '#card-change-perc', _context ).html(' (' + _change_perc + ')').addClass( 'up' )
    if _change_pips * 1 < 0
      $( '#card-change-pips', _context ).removeClass( 'up' ).addClass( 'down' )
      $( '#card-change-perc', _context ).removeClass( 'up' ).addClass( 'down' )
    $( '#card-ticker', _context ).html _ticker
    $( '#card-time', _context ).html _time
    $( '#card-date', _context ).html _date
    $( '#card-list-current', _context ).html _current_price
    $( '#card-list-change-perc', _context ).html _change_perc
    $( '#card-list-open', _context ).html _open
    $( '#card-list-max', _context ).html _max
    $( '#card-list-min', _context ).html _min
    $( '#card-list-close', _context ).html _close
    $( '#card-list-volume', _context ).html _volume
    $( '#card-chart', _context ).html '<img src="img/chart.jpg" width="560" height="324" alt="..."/>'

# Number formatter
Number::formatMoney = (c, d, t) ->
	n = this
	c = if isNaN(c = Math.abs(c)) then 2 else c
	d = if d == undefined then '.' else d
	t = if t == undefined then ',' else t
	s = if n < 0 then '-' else ''
	i = parseInt(n = Math.abs(+n or 0).toFixed(c)) + ''
	j = if (j = i.length) > 3 then j % 3 else 0
	s + (if j then i.substr(0, j) + t else '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + t) + (if c then d + Math.abs(n - i).toFixed(c).slice(2) else '') + ' ₽'

calcValue = (v) ->
	percent = $( '#profit-percent' ).data( 'value' ) * 1
	interval = $( 'input[name="calc_period"]:checked' ).val() * 1
	r = v / 100 * percent * interval
	(Math.floor(r,0)).formatMoney(0, '', ' ')

slider = document.getElementById('calc-range')
if slider?
	valueInput = document.getElementById('calc-range-input')
	noUiSlider.create slider,
		start: 100000,
		connect: 'lower',
		step: 10000,
		range:
			'min': 50000,
			'max': 3000000
		pips:
			mode: 'values',
			values: [50000, 500000, 1000000, 1500000, 2000000, 3000000],
			density: 10000,
			format: wNumb
				postfix: '&nbsp;т.',
				encoder: (value) ->
					value / 1000
	slider.noUiSlider.on 'update', ( values, handle ) ->
		rawValue = values[handle] * 1
		valueInput.value = (values[handle] * 1).formatMoney(0, '', ' ')
		$('.calculator #profit').text( calcValue(values[handle] * 1) )

	valueInput.addEventListener 'change', ->
		slider.noUiSlider.set([null, this.value])
