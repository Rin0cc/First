import anime from 'animejs'

document.addEventListener('DOMContentLoaded', () => {
  const animationBox = document.getElementById('record-animation')
  if (animationBox) {
    animationBox.style.display = 'block'
    anime({
      targets: '#record-animation',
      translateY: [-100, 0],
      opacity: [0, 1],
      duration: 1500,
      easing: 'easeOutBounce'
    })
  }
})
