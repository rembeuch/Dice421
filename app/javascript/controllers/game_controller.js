import { Controller } from "@hotwired/stimulus"



// Connects to data-controller="test"
export default class extends Controller {
  connect() {
  }

  addLap(event) {
    let gameId = event.target.dataset.id
    let lap = document.getElementById("lap")
    let maxlap = document.getElementById("maxlap")
    let btnLap = document.getElementById("btnLap")
    let locker = document.getElementById("locker")
    let result = document.getElementById("result")
    let btnTurn = document.getElementById("btnTurn")

    if (parseInt(lap.innerHTML) < 3) {
      lap.innerHTML = parseInt(lap.innerHTML) + 1

      btnTurn.classList.remove('d-none')
      locker.classList.remove('d-none')
      if (parseInt(maxlap.innerHTML) != 0) {
        if (parseInt(lap.innerHTML) > parseInt(maxlap.innerHTML)) {
          lap.innerHTML = parseInt(lap.innerHTML) - 1
          btnLap.classList.add('d-none')

          return
        }

      }

      const dices = [...document.querySelectorAll(".die-list")];
      dices.forEach(dice => {
        if (dice.classList.contains('unlock')) {

          dice.classList.toggle("odd-roll");
          dice.classList.toggle("even-roll");
          dice.dataset.roll = getRandomNumber(1, 6);
        }
      });
      let numArray = [document.getElementById('die-1').dataset.roll, document.getElementById('die-2').dataset.roll, document.getElementById('die-3').dataset.roll];
      numArray.sort(function (a, b) {
        return a - b;
      });
      let sortResult = numArray.sort(function (a, b) {
        return a - b;
      }).join("");
      btnLap.classList.add('d-none')

      fetch(`/results?score=${sortResult}`
        , {
          method: 'GET',
        })
        .then(response => response.json())
        .then(data => {
        })
      setTimeout(function () {
        if (parseInt(lap.innerHTML) < 3) {
          btnLap.classList.remove('d-none');
        }
        result.innerHTML = `résultat: ${document.getElementById('die-1').dataset.roll}.${document.getElementById('die-2').dataset.roll}.${document.getElementById('die-3').dataset.roll}`
      }, 2000);
    }

  }

  turn() {
    let lap = document.getElementById("lap")
    lap.innerHTML = 0
  }

  toggleLock(event) {
    event.currentTarget.classList.toggle("toggle");
    document.getElementById(`die-${event.currentTarget.dataset.lock}`).classList.toggle('unlock')
  }

}
function getRandomNumber(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
