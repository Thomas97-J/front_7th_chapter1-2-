export type RepeatType = 'daily' | 'weekly' | 'monthly' | 'yearly';

/**
 * 반복 일정 생성 옵션
 */
export interface RecurringRuleOptions {
  startDate: string; // YYYY-MM-DD 형식
  repeatType: RepeatType;
  count: number; // 생성할 반복 일정 개수
}

/**
 * 반복 일정 생성 결과
 */
export interface RecurringRuleResult {
  dates: { date: string; icon: string }[]; // 날짜와 아이콘
}

/**
 * 반복 일정 생성 로직
 *
 * @param options - 반복 일정 생성 옵션
 * @returns 생성된 반복 일정 날짜 배열
 */
export function scheduleRecurringRule(options: RecurringRuleOptions): RecurringRuleResult {
  const { startDate, repeatType, count } = options;

  // 시작 날짜 파싱
  const baseDate = new Date(startDate);
  const dates: string[] = [];

  switch (repeatType) {
    case 'daily':
      generateDailyDates(baseDate, count, dates);
      break;
    case 'weekly':
      generateWeeklyDates(baseDate, count, dates);
      break;
    case 'monthly':
      generateMonthlyDates(baseDate, count, dates);
      break;
    case 'yearly':
      generateYearlyDates(baseDate, count, dates);
      break;
  }

  return { dates };
}

/**
 * 매일 반복 일정 생성
 * 시작일 다음 날부터 하루씩 증가
 */
function generateDailyDates(baseDate: Date, count: number, dates: string[]): void {
  for (let i = 1; i <= count; i++) {
    const nextDate = new Date(baseDate);
    nextDate.setDate(nextDate.getDate() + i);
    dates.push(formatDate(nextDate));
  }
}

/**
 * 매주 반복 일정 생성
 * 같은 요일에 7일씩 증가
 */
function generateWeeklyDates(baseDate: Date, count: number, dates: string[]): void {
  for (let i = 1; i <= count; i++) {
    const nextDate = new Date(baseDate);
    nextDate.setDate(nextDate.getDate() + i * 7);
    dates.push(formatDate(nextDate));
  }
}

/**
 * 매월 반복 일정 생성
 * 같은 일(day)에만 생성. 해당 일이 없는 달은 건너뜀
 * 예: 31일 시작 -> 31일이 있는 달에만 생성
 */
function generateMonthlyDates(baseDate: Date, count: number, dates: string[]): void {
  const targetDay = baseDate.getDate();
  let currentYear = baseDate.getFullYear();
  let currentMonth = baseDate.getMonth() + 1; // 다음 달부터 시작

  let generatedCount = 0;
  let attempts = 0;
  const maxAttempts = count * 24; // 최대 2년 정도 탐색

  while (generatedCount < count && attempts < maxAttempts) {
    attempts++;

    if (currentMonth > 12) {
      currentMonth = 1;
      currentYear++;
    }

    // 해당 월에 targetDay가 존재하는지 확인
    const testDate = new Date(currentYear, currentMonth - 1, targetDay);

    // 날짜가 유효하고, 설정한 일(day)과 일치하는지 확인
    if (testDate.getDate() === targetDay && testDate.getMonth() === currentMonth - 1) {
      dates.push(formatDate(testDate));
      generatedCount++;
    }

    currentMonth++;
  }
}

/**
 * 매년 반복 일정 생성
 * 같은 월-일에만 생성. 해당 날짜가 없는 해는 건너뜀
 * 예: 2월 29일 시작 -> 윤년에만 생성
 */
function generateYearlyDates(baseDate: Date, count: number, dates: string[]): void {
  const targetMonth = baseDate.getMonth();
  const targetDay = baseDate.getDate();
  let currentYear = baseDate.getFullYear() + 1; // 다음 해부터 시작

  let generatedCount = 0;
  const maxYears = count * 10; // 최대 탐색 연도

  for (let yearOffset = 0; yearOffset < maxYears && generatedCount < count; yearOffset++) {
    const testYear = currentYear + yearOffset;
    const testDate = new Date(testYear, targetMonth, targetDay);

    // 날짜가 유효하고, 설정한 월-일과 일치하는지 확인
    if (testDate.getDate() === targetDay && testDate.getMonth() === targetMonth) {
      dates.push(formatDate(testDate));
      generatedCount++;
    }
  }
}

/**
 * Date 객체를 YYYY-MM-DD 형식 문자열로 변환
 */
function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
