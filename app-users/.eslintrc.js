module.exports = {
    "env": {
        "browser": true,
        "es6": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:vue/recommended"
    ],
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly"
    },
    "parserOptions": {
        "parser": "babel-eslint",
        "ecmaVersion": 2018,
        "sourceType": "module"
    },
    "plugins": [
        "vue"
    ],
    "rules": {
        "no-console": "off",
        "indent": [
            "error",
            4
        ],
        "vue/script-indent": [
            "error",
            4,
            { "baseIndent": 1 }
        ],
        "linebreak-style": [
            "error",
            "unix"
        ],
        "semi": [
            "error",
            "never"
        ],
        "no-unused-vars": [
            "error", { "argsIgnorePattern": "^_" }
        ],
        "vue/max-attributes-per-line": ["error", {
            "singleline": 4,
            "multiline": {
                "max": 4,
                "allowFirstLine": true
            }
        }]
    },
    "overrides": [
        {
            "files": ["*.vue"],
            "rules": {
                "indent": "off"
            }
        }
    ]
}