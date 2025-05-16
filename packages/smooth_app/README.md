Submodule containing all the logic of the Smoothie app.

In the future, it will receive as parameters:
- a barcode decoding algorithm  
- how to manage the review on the app store

## Documentation

We use `mkdocs` for our documentation. `mkdocs` is a static site generator that's geared towards project documentation. It is written in Python.

### How to use `mkdocs`

1. Install `mkdocs`:
   ```sh
   pip install mkdocs mkdocs-material
   ```

2. Serve the documentation locally:
   ```sh
   mkdocs serve
   ```

   This will start a local server at `http://127.0.0.1:8000/` where you can view the documentation.

3. Build the documentation:
   ```sh
   mkdocs build
   ```

   This will generate a static site in the `site` directory.

### Deploying the documentation

We use GitHub Pages to host our documentation. The deployment is handled automatically by a GitHub Actions workflow.

To manually deploy the documentation, you can use the following command:
```sh
mkdocs gh-deploy
```

This will build the documentation and push it to the `gh-pages` branch of the repository.
