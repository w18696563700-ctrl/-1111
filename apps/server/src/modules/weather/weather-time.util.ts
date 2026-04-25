const zhWeekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

export function formatClockLabel(
  value: string | null,
  timezone: string | null,
) {
  const date = toDate(value);
  if (!date) {
    return null;
  }

  const hour = padClockPart(readPart(date, timezone, 'hour'));
  const minute = padClockPart(readPart(date, timezone, 'minute'));
  if (hour == null || minute == null) {
    return null;
  }
  return `${hour}:${minute}`;
}

export function formatWeatherDateLabel(
  value: string,
  timezone: string | null,
) {
  const date = toDate(value);
  if (!date) {
    return {
      dateLabel: value,
      weekdayLabel: null,
    };
  }

  return {
    dateLabel: `${readPart(date, timezone, 'month') ?? '00'}/${readPart(date, timezone, 'day') ?? '00'}`,
    weekdayLabel: toWeekdayLabel(readPart(date, timezone, 'weekday')),
  };
}

export function formatRiskTimeLabel(
  value: string | null,
  timezone: string | null,
  prefix = '预计',
) {
  const clock = formatClockLabel(value, timezone);
  if (!clock) {
    return null;
  }
  return `${prefix}${clock}`;
}

export function isNightForecast(value: string, timezone: string | null) {
  const date = toDate(value);
  if (!date) {
    return false;
  }
  const hour = Number(readPart(date, timezone, 'hour'));
  return hour >= 18 || hour <= 6;
}

function toDate(value: string | null) {
  if (!value) {
    return null;
  }
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return new Date(`${value}T00:00:00+08:00`);
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function readPart(
  date: Date,
  timezone: string | null,
  type: Intl.DateTimeFormatPartTypes,
) {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: timezone ?? 'Asia/Shanghai',
    month: type === 'month' ? '2-digit' : undefined,
    day: type === 'day' ? '2-digit' : undefined,
    hour: type === 'hour' ? '2-digit' : undefined,
    minute: type === 'minute' ? '2-digit' : undefined,
    weekday: type === 'weekday' ? 'short' : undefined,
    hour12: false,
  }).formatToParts(date);
  return parts.find((part) => part.type === type)?.value ?? null;
}

function toWeekdayLabel(value: string | null) {
  switch (value) {
    case 'Sun':
      return zhWeekdays[0];
    case 'Mon':
      return zhWeekdays[1];
    case 'Tue':
      return zhWeekdays[2];
    case 'Wed':
      return zhWeekdays[3];
    case 'Thu':
      return zhWeekdays[4];
    case 'Fri':
      return zhWeekdays[5];
    case 'Sat':
      return zhWeekdays[6];
    default:
      return null;
  }
}

function padClockPart(value: string | null) {
  if (value == null) {
    return null;
  }
  return `${Number.parseInt(value, 10)}`.padStart(2, '0');
}
