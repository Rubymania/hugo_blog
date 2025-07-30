<script src="https://unpkg.com/lunr/lunr.js"></script>
<script>
fetch('/index.json')
  .then(response => response.json())
  .then(docs => {
    const idx = lunr(function () {
      this.ref('permalink');
      this.field('title');
      this.field('tags');
      this.field('description');
      this.field('content');

      docs.forEach(function (doc) {
        this.add(doc);
      }, this);
    });

    document.getElementById('search-input').addEventListener('input', function () {
      const results = idx.search(this.value);
      const container = document.getElementById('search-results');
      container.innerHTML = '';

      results.forEach(result => {
        const item = docs.find(d => d.permalink === result.ref);
        container.innerHTML += `<li><a href="${item.permalink}">${item.title}</a></li>`;
      });
    });
  });
</script>