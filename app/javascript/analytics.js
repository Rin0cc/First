import { Chart, registerables } from 'chart.js';
Chart.register(...registerables); 

import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';

// グラフとカレンダーの初期化処理を関数にまとめる
function initializeAnalytics() {
  // Chart.js - 日別記録時間グラフの描画
  const dailyTimeChartCanvas = document.getElementById('dailyTimeChart');
  if (dailyTimeChartCanvas && typeof window.chartData !== 'undefined' && typeof Chart !== 'undefined') {
    
    const recentChartData = window.chartData.slice(-7); 

    const labels = recentChartData.map(data => data.date);
    const dataValues = recentChartData.map(data => data.totalDurationMinutes);

    // 既存のChartインスタンスがあれば破棄する（再初期化のため）
    if (dailyTimeChartCanvas.chart) { 
      dailyTimeChartCanvas.chart.destroy();
    }

    const newChart = new Chart(dailyTimeChartCanvas, {
      type: 'bar', // 棒グラフ
      data: {
        labels: labels,
        datasets: [{
          label: '記録時間 (分)',
          data: dataValues,
          backgroundColor: 'rgb(216, 241, 255)',
          borderColor: 'rgb(189, 224, 174)',
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
    // 新しいChartインスタンスをcanvas要素に保存する
    dailyTimeChartCanvas.chart = newChart; 
  }

  // FullCalendar - カレンダーの描画
  const calendarEl = document.getElementById('calendar');
  if (calendarEl && typeof window.calendarEvents !== 'undefined' && typeof Calendar !== 'undefined') {
    // 既存のFullCalendarインスタンスがあれば破棄する（再初期化のため）
    if (calendarEl.calendar) {
      calendarEl.calendar.destroy();
    }

    const newCalendar = new Calendar(calendarEl, {
      plugins: [ dayGridPlugin, timeGridPlugin, interactionPlugin ],
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
      events: window.calendarEvents,
      eventClick: function(info) {
        alert('イベント: ' + info.event.title);
      },
      editable: false,
    }); 
    newCalendar.render();
    // 新しいCalendarインスタンスをcalendar要素に保存する
    calendarEl.calendar = newCalendar;
  }
}

document.addEventListener('turbo:load', initializeAnalytics); 

document.addEventListener('turbo:before-cache', () => {
  const dailyTimeChartCanvas = document.getElementById('dailyTimeChart');
  if (dailyTimeChartCanvas && dailyTimeChartCanvas.chart) {
    dailyTimeChartCanvas.chart.destroy();
    dailyTimeChartCanvas.chart = null;
  }
  const calendarEl = document.getElementById('calendar');
  if (calendarEl && calendarEl.calendar) {
    calendarEl.calendar.destroy();
    calendarEl.calendar = null;
  }
});