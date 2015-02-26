var keymap = {
    'meta': {'startView': 'view1'},

    'views': {
        'view1':  [

            // Line 1
            [
                {disp: 'q', value: 'q', action: 'data'},
                {disp: 'w', value: 'w', action: 'data'},
                {disp: 'e', value: 'e', action: 'data'},
                {disp: 'r', value: 'r', action: 'data'},
                {disp: 't', value: 't', action: 'data'},
                {disp: 'y', value: 'y', action: 'data'},
                {disp: 'u', value: 'u', action: 'data'},
                {disp: 'i', value: 'i', action: 'data'},
                {disp: 'o', value: 'o', action: 'data'},
                {disp: 'p', value: 'p', action: 'data'}
            ],

            // Line 2
            [
                {disp: 'a', value: 'a', action: 'data'},
                {disp: 's', value: 's', action: 'data'},
                {disp: 'd', value: 'd', action: 'data'},
                {disp: 'f', value: 'f', action: 'data'},
                {disp: 'g', value: 'g', action: 'data'},
                {disp: 'h', value: 'h', action: 'data'},
                {disp: 'j', value: 'j', action: 'data'},
                {disp: 'k', value: 'k', action: 'data'},
                {disp: 'l', value: 'l', action: 'data'}
            ],

            // Line 3
            [
                {disp: null, value: '\t', action: 'data', icon: "ionicons ion-arrow-right-c", moreClasses: "action"},
                {disp: 'z', value: 'z', action: 'data'},
                {disp: 'x', value: 'x', action: 'data'},
                {disp: 'c', value: 'c', action: 'data'},
                {disp: 'v', value: 'v', action: 'data'},
                {disp: 'b', value: 'b', action: 'data'},
                {disp: 'n', value: 'n', action: 'data'},
                {disp: 'm', value: 'm', action: 'data'},
                {disp: null, value: '\b', action: 'data', icon: "ionicons ion-backspace-outline",  moreClasses: "action"}
            ],

            // Line 4
            [

                {disp: null, value: 'view2', action: 'showView', icon: "fa fa-arrow-circle-o-up", moreClasses: "action"},
                {disp: null, value: 'view3', action: 'showView', icon: "ionicons ion-ios-infinite", moreClasses: "action"},
                {disp: '___', value: ' ', action: 'data'},
                {disp: null, value: 'view4', action: 'showView', icon: "fa fa-code", moreClasses: "action"},
                {disp: null, value: '\n', action: 'data', icon: "fa fa-arrow-left", moreClasses: "action"}
            ]
        ],

        'view2': [

            // Line 1
            [
            {disp: 'Q', value: 'Q', action: 'data'},
            {disp: 'W', value: 'W', action: 'data'},
            {disp: 'E', value: 'E', action: 'data'},
            {disp: 'R', value: 'R', action: 'data'},
            {disp: 'T', value: 'T', action: 'data'},
            {disp: 'Y', value: 'Y', action: 'data'},
            {disp: 'U', value: 'U', action: 'data'},
            {disp: 'I', value: 'I', action: 'data'},
            {disp: 'O', value: 'O', action: 'data'},
            {disp: 'P', value: 'P', action: 'data'}
            ],

            // Line 2
            [
                {disp: 'A', value: 'A', action: 'data'},
                {disp: 'S', value: 'S', action: 'data'},
                {disp: 'D', value: 'D', action: 'data'},
                {disp: 'F', value: 'F', action: 'data'},
                {disp: 'G', value: 'G', action: 'data'},
                {disp: 'H', value: 'H', action: 'data'},
                {disp: 'J', value: 'J', action: 'data'},
                {disp: 'K', value: 'K', action: 'data'},
                {disp: 'L', value: 'L', action: 'data'}
            ],

            // Line 3
            [
                {disp: null, value: '\t', action: 'data', icon: "ionicons ion-arrow-right-c", moreClasses: "action"},
                {disp: 'Z', value: 'Z', action: 'data'},
                {disp: 'X', value: 'X', action: 'data'},
                {disp: 'C', value: 'C', action: 'data'},
                {disp: 'V', value: 'V', action: 'data'},
                {disp: 'B', value: 'B', action: 'data'},
                {disp: 'N', value: 'N', action: 'data'},
                {disp: 'M', value: 'M', action: 'data'},
                {disp: null, value: '\b', action: 'data', icon: "ionicons ion-backspace-outline",  moreClasses: "action"}
            ],

            // Line 4
            [
                {disp: null, value: 'view1', action: 'showView', icon: "fa fa-arrow-circle-up", moreClasses: "action"},
                {disp: null, value: 'view3', action: 'showView', icon: "ionicons ion-ios-infinite", moreClasses: "action"},
                {disp: '___', value: ' ', action: 'data'},
                {disp: null, value: 'view4', action: 'showView', icon: "fa fa-code", moreClasses: "action"},
                {disp: null, value: '\n', action: 'data', icon: "fa fa-arrow-left", moreClasses: "action"}
            ]
        ],

        'view3': [
            // Line 1
            [
                {disp: '1', value: 1, action: 'data'},
                {disp: '2', value: 2, action: 'data'},
                {disp: '3', value: 3, action: 'data'},
                {disp: '4', value: 4, action: 'data'},
                {disp: '5', value: 5, action: 'data'},
                {disp: '6', value: 6, action: 'data'},
                {disp: '7', value: 7, action: 'data'},
                {disp: '8', value: 8, action: 'data'},
                {disp: '9', value: 9, action: 'data'},
                {disp: '0', value: 0, action: 'data'}
            ],

            // Line 2
            [
                {disp: '(', value: '(', action: 'data'},
                {disp: ')', value: ')', action: 'data'},
                {disp: '[', value: '[', action: 'data'},
                {disp: ']', value: ']', action: 'data'},
                {disp: '"', value: '"', action: 'data'},
                {disp: "'", value: "'", action: 'data'},
                {disp: ':', value: ':', action: 'data'},
                {disp: '=', value: '=', action: 'data'},
                {disp: '.', value: '.', action: 'data'}
            ],

            // Line 3
            [
                {disp: null, value: '\t', action: 'data', icon: "ionicons ion-arrow-right-c", moreClasses: "action"},
                {disp: '+', value: '+', action: 'data'},
                {disp: '-', value: '-', action: 'data'},
                {disp: '*', value: '*', action: 'data'},
                {disp: '/', value: '/', action: 'data'},
                {disp: '#', value: '#', action: 'data'},
                {disp: ',', value: ',', action: 'data'},
                {disp: '_', value: '_', action: 'data'},
                {disp: null, value: '\b', action: 'data', icon: "ionicons ion-backspace-outline",  moreClasses: "action"}
            ],

            // Line 4
            [
                {disp: null, value: 'view1', action: 'showView', icon: "fa fa-arrow-circle-o-up", moreClasses: "action"},
                {disp: null, value: 'view3.2', action: 'showView', icon: "ionicons ion-ios-infinite", moreClasses: "action"},
                {disp: '___', value: ' ', action: 'data'},
                {disp: null, value: 'view4', action: 'showView', icon: "fa fa-code", moreClasses: "action"},
                {disp: null, value: '\n', action: 'data', icon: "fa fa-arrow-left", moreClasses: "action"}
            ]
        ],

        'view3.2': [
            // Line 1
            [
                {disp: '1', value: 1, action: 'data'},
                {disp: '2', value: 2, action: 'data'},
                {disp: '3', value: 3, action: 'data'},
                {disp: '4', value: 4, action: 'data'},
                {disp: '5', value: 5, action: 'data'},
                {disp: '6', value: 6, action: 'data'},
                {disp: '7', value: 7, action: 'data'},
                {disp: '8', value: 8, action: 'data'},
                {disp: '9', value: 9, action: 'data'},
                {disp: '0', value: 0, action: 'data'}
            ],

            // Line 2
            [
                {disp: '~', value: '~', action: 'data'},
                {disp: '`', value: '`', action: 'data'},
                {disp: '!', value: '!', action: 'data'},
                {disp: '@', value: '@', action: 'data'},
                {disp: '$', value: '$', action: 'data'},
                {disp: '%', value: '%', action: 'data'},
                {disp: '^', value: '^', action: 'data'},
                {disp: '{', value: '{', action: 'data'},
                {disp: '}', value: '}', action: 'data'}
            ],

            // Line 3
            [
                {disp: null, value: '\t', action: 'data', icon: "ionicons ion-arrow-right-c", moreClasses: "action"},
                {disp: '&', value: '&', action: 'data'},
                {disp: '|', value: '|', action: 'data'},
//                            {disp: '\\', value: '\\', action: 'data'},
                {disp: ';', value: ';', action: 'data'},
                {disp: '<', value: '<', action: 'data'},
                {disp: '>', value: '>', action: 'data'},
                {disp: '?', value: '?', action: 'data'},
                {disp: null, value: '\b', action: 'data', icon: "ionicons ion-backspace-outline",  moreClasses: "action"}
            ],

            // Line 4
            [
                {disp: null, value: 'view1', action: 'showView', icon: "fa fa-arrow-circle-o-up", moreClasses: "action"},
                {disp: null, value: 'view3', action: 'showView', icon: "ionicons ion-ios-infinite", moreClasses: "action"},
                {disp: '___', value: ' ', action: 'data'},
                {disp: null, value: 'view4', action: 'showView', icon: "fa fa-code", moreClasses: "action"},
                {disp: null, value: '\n', action: 'data', icon: "fa fa-arrow-left", moreClasses: "action"}
            ]
        ],

        'view4': [
            // Line 1
            [
                {disp: 'if', value: 'if', action: 'data'},
                {disp: 'else', value: 'else', action: 'data'},
                {disp: 'elif', value: 'elif', action: 'data'}
            ],

            // Line 2
            [
                {disp: 'while', value: 'while', action: 'data'},
                {disp: 'for', value: 'for', action: 'data'},
                {disp: 'break', value: 'break', action: 'data'}
            ],

            // Line 3
            [
                {disp: null, value: '\t', action: 'data', icon: "ionicons ion-arrow-right-c", moreClasses: "action"},
                {disp: 'def', value: 'def', action: 'data'},
                {disp: 'return', value: 'return', action: 'data'},
                {disp: null, value: '\b', action: 'data', icon: "ionicons ion-backspace-outline",  moreClasses: "action"}
            ],

            // Line 4
            [
                {disp: null, value: 'view1', action: 'showView', icon: "fa fa-arrow-circle-o-up", moreClasses: "action"},
                {disp: null, value: 'view3', action: 'showView', icon: "ionicons ion-ios-infinite", moreClasses: "action"},
                {disp: '___', value: ' ', action: 'data'},
                {disp: null, value: 'view4', action: 'showView', icon: "fa fa-code", moreClasses: "action"},
                {disp: null, value: '\n', action: 'data', icon: "fa fa-arrow-left", moreClasses: "action"}
            ]
        ]
    }
};
