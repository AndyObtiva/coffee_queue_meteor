Meteor.startup =>
  if @Products.find().count() == 0
    names = {
        "Filtered": ["Large", "Medium", "Small"],
        "Latte": ["Regular", "Skim"],
        "Espresso": ["Single", "Double"],
        "Cappuccino": ["Standard"],
        "Mocha": ["Regular", "Regular Skim", "White", "White Skim", "Marble", "Marble Skim"],
        "Americano": ["Standard"],
        "Machiato": ["Regular", "Caramel"],
        "Frappucino": ["Regular", "Chocolate", "Vanilla"],
        "Cuban": ["Cortado", "Cortadito", "Cafe Con Leche"]
    };
    for name of names
      @Products.insert({name: name})
      options = names[name]
      @ProductOptions.insert(productName: name, name: option) for option in options
