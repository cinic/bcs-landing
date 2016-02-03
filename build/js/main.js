var getChartData, getLastNews, getNews;

$(function() {
  $('#tickers .radio-input[name*="ticker"]:checked').each(function(e) {
    return getLastNews(this);
  });
  $('.tab-body.active .radio-input[name*="ticker"]:checked').each(function(e) {
    getChartData(this);
    return getNews(this);
  });
  $('#tickers .radio-input[name*="ticker"]').on('change', function(e) {
    $(this).parents('.tab-body').find('.custom-radio').removeClass('checked');
    $(this).parent().addClass('checked');
    getLastNews(this);
    getChartData(this);
    return getNews(this);
  });
  $('.tab').on('click', function(e) {
    var _href;
    e.preventDefault();
    _href = $(this).attr('href');
    $(_href).siblings().removeClass('active').end().andSelf().addClass('active');
    $(this).siblings().removeClass('active').end().andSelf().addClass('active');
    return setTimeout(function() {
      return $('.tab-body.active .radio-input[name*="ticker"]:checked').each(function(e) {
        getChartData(this);
        return getNews(this);
      });
    }, 500);
  });
  $('.switch .item').on('click', function(e) {
    var _href;
    e.preventDefault();
    _href = $(this).attr('href');
    $(_href).siblings().removeClass('active').end().andSelf().addClass('active');
    return $(this).siblings().removeClass('active').end().andSelf().addClass('active');
  });
  return $('select').selectize();
});

getNews = function(elem) {
  var _ticker;
  _ticker = $(elem).val();
  return $.getJSON('news.json?ticker=' + _ticker, function(data) {
    var _items;
    _items = [];
    $('#meta-news-container').html('');
    return $.each(data['news'], function(key, val) {
      var _actions, _content, _item, _time, _title;
      _time = $('<time/>', {
        'class': 'date',
        html: val['datetime']
      });
      _title = $('<h4/>', {
        'class': 'title',
        html: val['title']
      });
      _content = $('<div/>', {
        'class': 'news-content',
        html: val['teaser']
      });
      _actions = $('<div/>', {
        'class': 'actions clearfix',
        html: '<a class="more" href="' + val['url'] + '">Подробнее</a>'
      });
      _item = $('<li/>', {
        'class': 'news-item'
      });
      _item.append(_time).append(_title).append(_content).append(_actions);
      return $('#meta-news-container').append(_item);
    });
  });
};

getLastNews = function(elem) {
  var _content, _target, _ticker, _time, _title;
  _ticker = $(elem).val();
  _time = $('<time/>', {
    'class': 'date'
  });
  _title = $('<h3/>', {
    'class': 'news-title'
  });
  _content = $('<div/>', {
    'class': 'news-content'
  });
  _target = $(elem).data('target');
  return $.getJSON('news.json?ticker=' + _ticker, function(data) {
    _time.html(data['news'][0]['datetime']);
    _title.html('<a href="' + data['news'][0]['url'] + '">' + data['news'][0]['title'] + '</a>');
    _content.html(data['news'][0]['teaser']);
    $('.news-item', _target).html('');
    return $('.news-item', _target).append(_time).append(_title).append(_content);
  });
};

getChartData = function(elem) {
  var _ticker;
  _ticker = $(elem).val();
  return $.getJSON('data.json?ticker=' + _ticker, function(data) {
    var _block_title, _change_perc, _change_pips, _close, _context, _current_price, _date, _exchange, _max, _min, _open, _time, _volume;
    _context = $('#graph');
    _exchange = data['exchange'];
    _current_price = data['price']['current'];
    _change_pips = data['price']['change_pips'];
    _change_perc = data['price']['change_percent'];
    _open = data['price']['open'];
    _max = data['price']['max'];
    _min = data['price']['min'];
    _close = data['price']['close'];
    _volume = data['price']['volume'];
    _ticker = data['ticker'];
    _time = data['time'];
    _date = data['date'];
    _block_title = data['block_title'];
    $('#container-title span').html(_block_title);
    $('#card-change-pips, #card-change-perc', _context).removeClass('up down');
    $('#data-title', _context).html(_exchange);
    $('#card-current-price', _context).html(_current_price);
    $('#card-change-pips', _context).html(_change_pips).addClass('up');
    $('#card-change-perc', _context).html(' (' + _change_perc + ')').addClass('up');
    if (_change_pips * 1 < 0) {
      $('#card-change-pips', _context).removeClass('up').addClass('down');
      $('#card-change-perc', _context).removeClass('up').addClass('down');
    }
    $('#card-ticker', _context).html(_ticker);
    $('#card-time', _context).html(_time);
    $('#card-date', _context).html(_date);
    $('#card-list-current', _context).html(_current_price);
    $('#card-list-change-perc', _context).html(_change_perc);
    $('#card-list-open', _context).html(_open);
    $('#card-list-max', _context).html(_max);
    $('#card-list-min', _context).html(_min);
    $('#card-list-close', _context).html(_close);
    $('#card-list-volume', _context).html(_volume);
    return $('#card-chart', _context).html('<img src="img/chart.jpg" width="560" height="324" alt="..."/>');
  });
};
