export type RepeatType = 'daily' | 'weekly' | 'monthly' | 'yearly';

/**
 * Generates recurring dates based on a start date, repeat type, and count
 *
 * @param startDate - The start date in YYYY-MM-DD format
 * @param repeatType - The type of recurrence (daily, weekly, monthly, yearly)
 * @param count - The number of recurring dates to generate
 * @returns Array of date strings in YYYY-MM-DD format
 * @throws Error if inputs are invalid
 */
export function generateRecurringDates(
  startDate: string,
  repeatType: RepeatType,
  count: number
): string[] {
  // Input validation
  if (count < 0) {
    throw new Error('Count cannot be negative');
  }

  if (count === 0) {
    return [];
  }

  // Validate repeat type
  const validRepeatTypes: RepeatType[] = ['daily', 'weekly', 'monthly', 'yearly'];
  if (!validRepeatTypes.includes(repeatType)) {
    throw new Error(`Invalid repeat type: ${repeatType}`);
  }

  // Validate and parse start date
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  if (!dateRegex.test(startDate)) {
    throw new Error('Invalid date format. Expected YYYY-MM-DD');
  }

  const baseDate = new Date(startDate);
  if (isNaN(baseDate.getTime())) {
    throw new Error('Invalid date value');
  }

  // Extract day, month, year from start date
  const startDay = baseDate.getDate();
  const startMonth = baseDate.getMonth();
  const startYear = baseDate.getFullYear();

  const result: string[] = [];

  // Generate recurring dates based on type
  switch (repeatType) {
    case 'daily':
      generateDailyDates(baseDate, count, result);
      break;
    case 'weekly':
      generateWeeklyDates(baseDate, count, result);
      break;
    case 'monthly':
      generateMonthlyDates(startDay, startMonth, startYear, count, result);
      break;
    case 'yearly':
      generateYearlyDates(startDay, startMonth, startYear, count, result);
      break;
  }

  console.log('result:', result);
  return result;
}

/**
 * Generates daily recurring dates
 */
function generateDailyDates(baseDate: Date, count: number, result: string[]): void {
  const current = new Date(baseDate);
  for (let i = 0; i < count; i++) {
    result.push(formatDate(current)); // 시작일 포함
    current.setDate(current.getDate() + 1);
  }
}

/**
 * Generates weekly recurring dates (same day of week)
 */
function generateWeeklyDates(baseDate: Date, count: number, result: string[]): void {
  const current = new Date(baseDate);
  for (let i = 0; i < count; i++) {
    result.push(formatDate(current)); // 시작일 포함
    current.setDate(current.getDate() + 7);
  }
}

/**
 * Generates monthly recurring dates
 * Only generates dates when the target day exists in the month
 */
function generateMonthlyDates(
  startDay: number,
  startMonth: number,
  startYear: number,
  count: number,
  result: string[]
): void {
  let currentYear = startYear;
  let currentMonth = startMonth;
  let generated = 0;

  // 첫 달(시작월)부터 체크
  while (generated < count) {
    if (isValidDate(currentYear, currentMonth, startDay)) {
      const date = new Date(currentYear, currentMonth, startDay);
      result.push(formatDate(date));
      generated++;
    }
    currentMonth++;
    if (currentMonth > 11) {
      currentMonth = 0;
      currentYear++;
    }
  }
}

/**
 * Generates yearly recurring dates
 * For Feb 29, only generates on leap years
 */
function generateYearlyDates(
  startDay: number,
  startMonth: number,
  startYear: number,
  count: number,
  result: string[]
): void {
  let currentYear = startYear;
  let generated = 0;

  // 첫 해(시작년도)부터 체크
  while (generated < count) {
    if (isValidDate(currentYear, startMonth, startDay)) {
      const date = new Date(currentYear, startMonth, startDay);
      result.push(formatDate(date));
      generated++;
    }
    currentYear++;
  }
}
/**
 * Checks if a date is valid
 *
 * @param year - Year value
 * @param month - Month value (0-11)
 * @param day - Day value (1-31)
 * @returns true if the date exists, false otherwise
 */
function isValidDate(year: number, month: number, day: number): boolean {
  const date = new Date(year, month, day);
  return date.getFullYear() === year && date.getMonth() === month && date.getDate() === day;
}

/**
 * Checks if a year is a leap year
 *
 * @param year - Year to check
 * @returns true if leap year, false otherwise
 */
function isLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

/**
 * Formats a Date object to YYYY-MM-DD string
 *
 * @param date - Date object to format
 * @returns Formatted date string in ISO 8601 format
 */
function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
