import '../../assets/stylesheets/users.scss'

document.addEventListener('click', (event) => {
  if (event.target.matches('.copy-signature')) {
    const input = document.querySelector('input.signature-input')
    input.select()

    document.execCommand('copy')
    window._paq.push(['trackEvent', 'User Profile', 'BB Code Copied'])
  }

  if (event.target.matches('li.square > a')) {
    window._paq.push(['trackEvent', 'User Profile', 'Calendar Navigation', event.target.href])
  }
})
