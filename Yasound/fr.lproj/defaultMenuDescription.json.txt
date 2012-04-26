[
                  {
                   "name": "Ma radio",
                   "entries":[
                              { "id":"myRadio", "name": "Ma radio", "image": "IconMyRadio", "type": "my_radio"}
                              ]
                   },
                  {
                   "name": "Radios",
                   "entries":[
                              { "id":"radioMyFriends", "name": "Mes amis", "image": "IconRadiosFriends", "type": "friends"},
                              { "id":"radioMyFavorites", "name": "Mes favoris", "image": "IconRadiosFavorites", "type": "radio_list", "params": {"url":"/api/v1/favorite_radio", "genre_selection":false}},
                              { "id":"radioSelection", "name": "Sélection", "image": "IconRadiosSelection", "type": "radio_list", "params": {"url":"/api/v1/selected_radio"}},
                              { "id":"radioTop", "name": "Top", "image": "IconLeaderboard", "type": "radio_list", "params": {"url":"/api/v1/top_radio"}},
                              { "id":"radioSearch", "name": "Recherche", "image": "IconRadiosSearch", "type": "search_radio"}
                              ]
                   },
                   {
                   "name": "Moi",
                   "entries":[
                              { "id":"meNotifications", "name": "Mes notifications", "image": "IconMeNotifs", "type": "notifications"},
                              { "id":"meStats", "name": "Mes statistiques", "image": "IconMeStats", "type": "stats"},
                              { "id":"meProgramming", "name": "Ma programmation", "image": "IconMePlaylists", "type": "programming"},
                              { "id":"meSettings", "name": "Paramètres", "image": "IconMeSettings", "type": "settings"}
                              ]
                   },
                   {
                   "name": "Divers",
                   "entries":[
                              { "id":"miscLegal", "name": "Conditions d'utilisation", "image": "IconMiscLegal", "type": "web_page", "params":{"url":"legal/eula.html"}},
                              { "id":"miscLogout", "name": "Se déconnecter", "image": "IconMiscLogout", "type": "logout"}
                              ]
                   }
]