// Chart.js のインポート
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables); // これでChart.jsのすべての機能が使えるようになる

// FullCalendar のインポート
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';      // 月表示のため
import timeGridPlugin from '@fullcalendar/timegrid';    // 週・日表示のため（必要なら）
import interactionPlugin from '@fullcalendar/interaction'; // ドラッグ＆ドロップなどインタラクションのため（必要なら）