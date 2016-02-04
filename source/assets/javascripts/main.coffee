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

  $( '#calc-range-input' ).on 'focus', ->
    $( @ ).blur()
  $('input[name="calc_period"]').on 'change', ->
    value = $('.calculator #calc-range-input').val().match(/([0-9\s]+)( ₽)/)[1].replace(/\s/g, "") * 1
    $( 'input[name="calc_period"]' ).parent().removeClass('active')
    $( @ ).parent().addClass('active')
    $('.calculator #profit').text( calcValue( value, value ) )
    $('.calculator #profit-period').text( calcValue( value ) )
    $( '#stock-buy-date' ).html( $( @ ).data('date_buy') )
    $( '#stock-sell-date' ).html( $( @ ).data('date_sell') )
    $( '#stock-buy-price' ).html 'по ' + $( @ ).data('price_buy') + ' руб'
    $( '#stock-sell-price' ).html 'по ' + $( @ ).data('price_sell') + ' руб'
    $( '#profit-percent' ).html( $( @ ).data('profit_percent') + ' %' )
    $( '#profit-time' ).html( $( @ ).parent().text() )

darkBox = ( e ) ->
  e.preventDefault()
  e.stopPropagation()
  darkbox = $('<div class="darkbox"><div class="fix-scroll"><div class="darkbox-shadow"></div><div class="container"><div class="darkbox-container radius"><span class="darkbox-close"></span><div class="darkbox-content"></div></div></div></div></div>');
  wH = $(window).height() + 30;
  _elem = $( e.target ).attr('href')
  _news = $( '<div/>', { 'class': 'meta', html: '<div class="meta-news-container">' + $( _elem ).html() + '</div>' } )
  $( 'body' ).css('overflow','hidden').append( darkbox );
  $( '.fix-scroll' ).height( wH );
  # Resize window
  if ($( '.fix-scroll' ).length > 0)
    $( window ).resize ->
      $( '.fix-scroll' ).height( $( window ).height() + 30 )
  $( '.darkbox-content' ).append( _news )
  $( '.darkbox-close, .darkbox .darkbox-shadow' ).on 'click', ->
    darkbox.remove()
    $( 'body' ).css('overflow','auto')

getNews = ( elem ) ->
  _ticker = $(elem).val()
  $.getJSON 'news.json?ticker=' + _ticker, ( data ) ->
    _items = []
    $( '#meta-news-container' ).html( '' )
    $.each data['news'], ( key,val ) ->
      _time = $( '<time/>', { 'class': 'date', html: val['datetime'] } )
      _title = $( '<h4/>', { 'class': 'title', html: val['title'] } )
      _content = $( '<div/>', { 'class': 'news-content', html: val['teaser'] } )
      _content_full = $( '<div/>', { 'class': 'news-content full', html: val['content'] } )
      _actions = $( '<div/>', { 'class': 'actions clearfix', html: '<a class="more" href="#news-id-' + val['id'] + '">Подробнее</a>' } )
      _item = $( '<li/>', { 'class': 'news-item', 'id': 'news-id-' + val['id'] } )
      _item.append( _time ).append( _title ).append( _content ).append( _content_full ).append( _actions )
      $( '#meta-news-container' ).append( _item )
    # Darkbox
    $( 'a.more' ).on 'click', (e) ->
      darkBox(e)

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
    # calculator data
    _company_title = data['company']['title']
    _company_text = data['company']['text']
    _calculator_3 = data['calculator']['3']
    _calculator_6 = data['calculator']['6']
    _calculator_12 = data['calculator']['12']

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

    $( '#description-title' ).html _company_title
    $( '#description-text' ).html _company_text
    $( '#calc-period-3' ).data( _calculator_3 )
    $( '#calc-period-6' ).data( _calculator_6 )
    $( '#calc-period-12' ).data( _calculator_12 )
    $( '#stock-buy-date' ).html _calculator_6['date_buy']
    $( '#stock-sell-date' ).html _calculator_6['date_sell']
    $( '#stock-buy-price' ).html 'по ' + _calculator_6['price_buy'] + ' руб'
    $( '#stock-sell-price' ).html 'по ' + _calculator_6['price_sell'] + ' руб'
    $( '#profit-percent' ).html _calculator_6['profit_percent'] + ' %'
    slider.noUiSlider.set(250000)
    $( 'input#calc-period-6' ).prop('checked', true).change()


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

calcValue = (v, b) ->
  percent = $( 'input[name="calc_period"]:checked' ).data( 'profit_percent' ) * 1
  interval = $( 'input[name="calc_period"]:checked' ).val() * 1
  r = v / 100 * percent * interval
  r = r + b if b?
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
    valueInput.value = (rawValue).formatMoney(0, '', ' ')
    $('.calculator #profit').text( calcValue(rawValue, rawValue) )
    $('.calculator #profit-period').text( calcValue(rawValue) )

	valueInput.addEventListener 'change', ->
		slider.noUiSlider.set([null, this.value])
