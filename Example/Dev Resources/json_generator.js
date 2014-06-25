[
  '{{repeat(100,100)}}',
  {
    id: '{{index()}}',
    name: '{{firstName()}} {{surname()}}',
    gender: '{{gender()}}',
    bio: '{{lorem(1, "sentences")}}',
    address: {
      street: '{{integer(100,1000)}} {{street()}}',
      city: '{{city()}}',
      state: '{{state()}}'
    },
    interests: [
      '{{repeat(1,3)}}',
      function randomInterests(tags, index) {
        
        var interests = [ ["swimming", "hiking", "skiing"],
                          ["gardening", "cooking", "painting"],
                          ["music", "sports", "movies"] ];
        return interests[index][Math.floor(Math.random() * 3)];
      }
    ]
  }
]
