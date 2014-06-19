// random json from www.json-generator.com

[
  '{{repeat(100,100)}}',
  {
    id: '{{index()}}',
    name: '{{firstName()}} {{surname()}}',
    gender: '{{gender()}}',
    bio: '{{lorem(1, "sentences")}}',
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
