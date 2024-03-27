# Codestyle

Uses eslint `4.x`

```
npm install codestyle --save-dev
```

Create `.eslintrc` file in the root of your project:

- Generic rules set:

    ```JSON
    {
        "extends": "./node_modules/codestyle/.eslintrc"
    }
    ```

- React specific rules:

    ```JSON
    {
        "extends": "./node_modules/codestyle/.react-eslintrc"
    }
    ```
