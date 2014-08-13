'use strict'
$ = (id) ->
  document.getElementById id

app = angular.module('daisy', ['ngRoute', 'ui.bootstrap'])
app.run ($location, $rootScope, $window) ->
  common = $rootScope.common = $rootScope.common || {
    clear: ->
      delete $window.sessionStorage.data
      $window.location.replace '/'
  }
app.config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix('!');
  $routeProvider
    .when '/',
      templateUrl: '/views/home.html'
      controller: 'HomeCtrl'
    .when '/lights',
      templateUrl: '/views/lights.html'
      controller: 'LightsCtrl'
    .when '/lights/:name',
      templateUrl: '/views/lights.html'
      controller: 'LightsCtrl'
    .when '/news',
      templateUrl: '/views/news.html'
      controller: 'NewsCtrl'
    .when '/about',
      templateUrl: '/views/about.html'
      controller: 'AboutCtrl'
    .otherwise
      redirectTo: '/'

# app.directive 'ngClear', ($window, $routeParams, $http, Data) ->
#   link: (scope, elm) ->
#     elm.bind 'click', ->
#       store.clear()
#       $http.get('/js/lights.json').success (rs) ->
#         # obj = {}
#         nums = {}

#         nums[tag] = 0 for tag in Data.tags
#         nums[cat.k] = 0 for cat in Data.categorys
        
#         angular.forEach rs, (val) ->
#           nums[val.c] += 1
#           for t in val.ts
#             nums[t] += 1
          
#         Data.lights = rs
#         Data.nums = nums
#         store.set 'data', [rs, nums]

#         scope.$$childHead.lights = rs if scope.$$childHead.lights
#         if name = $routeParams.name
#             angular.forEach rs, (light) ->
#               scope.$$childHead.light = light if light.n is name


app.directive 'demo', (Data) ->
  link: (scope, elm) ->
    elm.bind 'click', ->
      scope.$$childHead.show?(null)
      scope.$apply()
      

app.directive 'x', ($location) ->
  link: (scope, elm) ->
    elm.find('a').eq(0).bind 'click', ->
      $li = elm.find 'li'
      elm.find('li').removeClass 'active'
      scope.x = false


app.directive 'xx', ($location) ->
  link: (scope, elm) ->
    $page = $ $location.path().split('/')[1]
    $page?.classList.add 'active'
    $li = elm.find 'li'
    $li.bind 'click', ->
      $li.removeClass 'active'
      this.classList.add 'active' 
      scope.x = false
  

app.factory 'Data', ($http) ->
  obj = {}
  obj.tags = ['1W', '3W', '8W', '10W', '12W', '15W', '25W', 'Other', 'PAR46', 'PAR64', 'PAR575', 'Flat PAR', 'INDOOR', 'OUTDOOR', 'FULL COLOR', 'SINGLE COLOR']
  obj.marks = s3: 'RGB', s4: 'RGBA/W', s5: 'RGBAW', m2: 'WW 二合一', m3: '三合一', m4: '四合一', m5: '五合一', m6: '六合一', ip20: '防护等级 20', ip65: '防护等级 65', ip67: 'IP67', sd: '声音控制', wl: '无线控制', dmx: 'DMX 512', auto: '程序自走', flick: '无闪烁', charge: '可反复充电', live: 'LIVE', cast: '航空箱包装', disco: 'Disco'
  obj.categorys = [
    {k: 'par', v: 'LED 帕灯'}
    {k: 'moving', v: 'LED 摇头灯'}
    {k: 'washer', v: 'LED 洗墙灯'}
    {k: 'city', v: '城市之光'}
    {k: 'other', v: '其他'}
  ]

  obj.addMessage = (message) ->
    $http.post('https://daisylight.firebaseio.com/messages.json', JSON.stringify(message))
    # new Firebase('https://flickering-fire-6969.firebaseio.com/').push message

  if !store.get 'data'
    $http.get('/js/lights.json').success (rs) ->
      nums = {}
      nums[tag] = 0 for tag in obj.tags
      nums[cat.k] = 0 for cat in obj.categorys
      
      angular.forEach rs, (val) ->
        nums[val.c] += 1
        for t in val.ts
          nums[t] += 1
        
      obj.lights = rs
      obj.nums = nums
      store.set 'data', [rs, nums]
  else
    data = store.get 'data'
    obj.lights = data[0]
    obj.nums = data[1]
  obj



app.controller 'HomeCtrl', ($scope, $location, Data) ->
  $scope.tops = ['CT80', 'PS1212', 'LF2512', 'AWS1209', 'ML140-BEAM', 'PF1012']
  $scope.says = [
    {who: 'Mr. Klaus', hi:'One of Germany customer, said: We import products from your company for more than 6 years already because you never disappoint us on quality and delivery time.'}
    {who: 'Mr. Stephen', hi: 'One of USA customer, said: I buy goods from China many years but I never meet any company like your company efficient. Every email I sent will be detailed reply by you within 10 minutes. Always I can get information from you in time.'}    
    {who: 'Mr. Hong', hi: 'One of South Korea customer, said: you save many times for me because I almost have not got complain from my customers again since we import Cases from your company.'}    
    {who: 'Miss Anita', hi: 'One of Spain customer, said: 2 years ago, we were a new company and do not know products and market very well. But you still support us and help us to develop market. You are our the best partner in China!'}    
    {who: 'Mr. Sveta', hi: 'From Russia company, said: I can keep strong competitiveness in big Russia market these years because of your good quality and competitive price. Could you please do not sell the goods to another Russia company for to keep our company competitive?'}    
  ]
  $scope.$on '$routeChangeStart', (next, current) ->
    page = $location.path()
    if page.indexOf('/lights') > -1
      $('lights').classList.add('active') 
      # document.getElementById('lights').classList.add('active')

app.controller 'LightsCtrl', ($scope, $routeParams, $anchorScroll, Data) ->
  $scope.lights = Data.lights
  $scope.marks = Data.marks
  $scope.categorys = Data.categorys
  $scope.tags = Data.tags 
  $scope.nums = Data.nums

  $scope.addMessage = (message) ->
    message.time = new Date().getTime()# "#{d.getFullYear()}-#{d.getMonth()}-#{d.getDate()}"
    Data.addMessage(message).success (res) ->
      $anchorScroll()
      $scope.message.content = ''
  
  

  $scope.setCategory = (category) ->
    $scope.xx = false
    $anchorScroll()
    $scope.light = ''
    $scope.search = c: category
    $scope.title = '全部产品'
    angular.forEach $scope.categorys, (val) -> $scope.title = val.v if val.k is category
  
  $scope.setMark = (mk) ->
    $anchorScroll()
    $scope.light = ''
    $scope.search = ms: mk
    $scope.title = "Marks: #{$scope.marks[mk]}"
  $scope.setTag = (tag) ->
    $anchorScroll()
    $scope.light = ''
    $scope.search = ts: tag
    $scope.title = "Tags: #{tag}"
  
  $scope.show = (light, index) ->
    $anchorScroll()
    $scope.message = {}
    $scope.search = c: light?.c, ts: light?.ts
    $scope.light = light
    $scope.title = light?.n
    # $scope.relateds = shuffle $scope.lights, 4
    $scope.relateds = (angular.copy($scope.lights).sort -> 0.5 - Math.random()).slice 0, 4


    $scope.send = (message) ->
      console.log message
      $scope.message.content = ''

  if name = $routeParams.name
    angular.forEach $scope.lights, (val) -> $scope.show(val) if val.n is name
        
app.controller 'NewsCtrl', ($scope) ->
  console.log 'news...'

app.controller 'AboutCtrl', ($scope, Data) ->
  $scope.slides = [
    {img: 1, desc: 'The workshop'}
    # {img: 2, desc: 'The workshop 2'}
    {img: 3, desc: 'Single chip microcomputer'}
    # {img: 4, desc: 'Single chip microcomputer'}
    {img: 5, desc: 'Single chip microcomputer'}
    {img: 6, desc: 'Single chip microcomputer'}
    {img: 7, desc: 'The plug-in'}
    {img: 8, desc: 'Working'}
    {img: 9, desc: 'Waterproof test'}
    {img: 10, desc: 'Aging test'}
    {img: 11, desc: 'Lighting show'}
  ]

