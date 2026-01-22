// search.js
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
      this.field('summary');
      this.field('author');
      this.field('date'); // <--- date 필드를 Lunr.js 인덱싱에 추가

      docs.forEach(function (doc) {
        this.add(doc);
      }, this);
    });

    document.getElementById('search-input').addEventListener('input', function () {
      const results = idx.search(this.value);
      const container = document.getElementById('search-results');
      container.innerHTML = '';

      if (results.length === 0) {
        container.innerHTML = '<li>검색 결과가 없습니다.</li>';
        return;
      }

      results.forEach(result => {
        const item = docs.find(d => d.permalink === result.ref);
        if (item) {
          const pageTitle = item.title || '제목 없음';
          const pageAuthor = item.author || '플랜트마루';
          const pageSummary = item.summary || '';
          const pageDate = item.date || ''; // 날짜도 가져와서 undefined 방지

          container.innerHTML += `
            <li>
              <a href="${item.permalink}">${pageTitle}</a>
              ${pageAuthor ? ` <span>(by ${pageAuthor})</span>` : ''}
              ${pageDate ? ` <span>(${pageDate})</span>` : ''} ${pageSummary ? `<p>${pageSummary}</p>` : ''}
            </li>
          `;
        }
      });
    });
  });
</script>