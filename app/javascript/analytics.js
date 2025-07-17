
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables); 

import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';

document.addEventListener('DOMContentLoaded', () => {
  // Chart.js - 日別記録時間グラフの描画
  const dailyTimeChartCanvas = document.getElementById('dailyTimeChart');
  // ここを修正！ ↓ window.chartData を使う
  if (dailyTimeChartCanvas && typeof window.chartData !== 'undefined' && typeof Chart !== 'undefined') {
    const labels = window.chartData.map(data => data.date);
    const dataValues = window.chartData.map(data => data.totalDurationMinutes);

    new Chart(dailyTimeChartCanvas, {
      type: 'bar', // 棒グラフ
      data: {
        labels: labels,
        datasets: [{
          label: '記録時間 (分)',
          data: dataValues,
          backgroundColor: 'rgba(255, 159, 64, 0.5)',
          borderColor: 'rgba(255, 159, 64, 1)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: '時間 (分)'
            }
          },
          x: {
            title: {
              display: true,
              text: '日付'
            }
          }
        }
      }
    });
  }

  // FullCalendar - カレンダーの描画
  const calendarEl = document.getElementById('calendar');
  // ここを修正！ ↓ window.calendarEvents を使う
  if (calendarEl && typeof window.calendarEvents !== 'undefined' && typeof Calendar !== 'undefined') {
    const calendar = new Calendar(calendarEl, {
      plugins: [ dayGridPlugin, timeGridPlugin, interactionPlugin ], // プラグインはここでインポートした変数名でOK
      initialView: 'dayGridMonth',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      buttonText: {
        today: '今日',
        month: '月',
        week: '週',
        day: '日'
      },
      locale: 'ja',
      events: window.calendarEvents, // ここを修正！ ↓
      eventClick: function(info) {
        alert('イベント: ' + info.event.title);
      },
      editable: true,
      eventDrop: function(info) {
        console.log('イベントが移動しました:', info.event);
      },
      eventResize: function(info) {
        console.log('イベントがリサイズされました:', info.event);
      }
    });
    calendar.render();
  }
});