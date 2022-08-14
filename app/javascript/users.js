document.addEventListener('turbo:load', function () {
  document.querySelector('.copy-signature').onclick = function () {
    const input = document.querySelector('input.signature-input')
    input.focus()
    input.select()

    document.execCommand('copy')
    window._paq.push(['trackEvent', 'User Profile', 'BB Code Copied'])
  }

  document.addEventListener('click', function (event) {
    if (event.target.matches('li.square > a')) {
      window._paq.push(['trackEvent', 'User Profile', 'Calendar Navigation', event.target.href])
    }
  })
})
