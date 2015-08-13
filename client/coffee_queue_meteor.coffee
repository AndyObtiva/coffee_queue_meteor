Accounts.ui.config(passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL')
formDescriptionObject = {
  id: "orderForm"
  fields:{
    name: {
      required: true
    },
  }
}
Mesosphere(formDescriptionObject)
Template.order.helpers
  products: ->
    Products.find().fetch()

  productOptions : ->
    productName = Session.get("productName") || 'Filtered'
    ProductOptions.find({productName: productName}).fetch()

Template.loginButtons.events
  'click .login-link-text' : (event) ->
    $('#login-dropdown-list').css('opacity', 0)
    $('#login-dropdown-list').animate('opacity': 1)

Template.order.events
  'change select#productName' : (event) ->
    Session.set("productName", $('select#productName').val())
  ,
  # TODO support ENTER key submit of form (seems disabled in Meteor by default) [http://stackoverflow.com/questions/13010151/input-text-return-event-in-meteor]
  'click input[type=submit]' : (event) ->
    rawFormData = {
      name: $('input#name').val(),
      createdAt: new Date(),
      product: {
        name: $('select#productName').val()
      },
      productOption:  {
        name: $('select#productOptionName').val(),
        productName: $('select#productName').val()
      }
    }
    Mesosphere.orderForm.validate rawFormData, (errors, formData) ->
      if errors
        $('#orderForm span').addClass('error')
      else
        $('#orderForm span').removeClass('error')
        Orders.insert(
          rawFormData
        )


Template.orders.helpers
  customerOrders : (orders=null) ->
    orders = Orders.find().fetch() unless orders
    _.map(orders, (order) -> new CustomerOrder(order))
  ordersInProgress : ->
    _.filter(Template.orders.__helpers.get('customerOrders')(), (order) -> order.waiting())
  noOrdersInProgress : ->
    Template.orders.__helpers.get('ordersInProgress')().length == 0
  readyOrders : ->
    _.filter(Template.orders.__helpers.get('customerOrders')(), (order) -> order.ready())
  fulfilledOrders : ->
    _.filter(Template.orders.__helpers.get('customerOrders')(), (order) -> order.fulfilled())

Template.orders.events
  'click input[type=button]' : (event) ->
    customerId = $(event.target).data('id')
    order = Orders.findOne({_id: customerId})
    order = new CustomerOrder(order)
    newStatus = if order.waiting() then 'ready' else 'served'
    fulfilledAt = if order.waiting() then new Date() else order.fulfilledAt
    Orders.update(
      {_id: order._id},
      {
        name: order.name,
        product: order.product,
        productOption: order.productOption,
        createdAt: order.createdAt,
        state: newStatus,
        fulfilledAt: fulfilledAt,
        baristaId: Meteor.userId()
      }
    )


Template.stats.helpers
  averageWaitTimeForOrders : (orders) ->
    return 0 if orders.length == 0
    averageTime = 0
    count = 0
    _.each(orders, (order) ->
      oneHourAgo = moment().subtract(1, 'hour');
      if order.fulfilledAt && order.createdAt && order.createdAt > oneHourAgo
        averageTime += (order.fulfillmentTime())
        count += 1
    )
    (averageTime / count) / 1000

  averageWaitTime : ->
    fulfilledOrders = Template.orders.__helpers.get('fulfilledOrders')()
    parseInt(Template.stats.__helpers.get('averageWaitTimeForOrders')(fulfilledOrders))

  fastestBarista : ->
    baristas = Baristas.find().fetch()
    _.each baristas, (barista) =>
      baristaOrders = Orders.find(baristaId: barista._id).fetch()
      customerOrders = Template.orders.__helpers.get('customerOrders')(baristaOrders)
      fastestOrder = _.min customerOrders, (customerOrder) -> customerOrder.fulfillmentTime()
      barista.fastestTime = parseInt((if customerOrders.length then fastestOrder.fulfillmentTime() else 999999)/1000)

    fastest = _.min baristas, (barista) -> barista.fastestTime
    fastest.emailAddress = fastest.emails[0].address
    fastest


#  Template.loginButtons.events({
#    'click #login-buttons' : (event) ->
#      $('.main-lane.box').animate({height: 400})
#  })
