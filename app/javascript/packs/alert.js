
export default document.addEventListener('click', (event) => {
  if (!event.target.matches('.notification button.delete')) return

  const notification = event.target.parentNode
  notification.parentNode.removeChild(notification)
})
