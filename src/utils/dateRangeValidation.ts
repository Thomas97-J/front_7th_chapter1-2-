/**
 * 날짜 범위 검증 결과 인터페이스
 */
export interface ValidationResult {
  isValid: boolean;
  error?: string;
  warning?: string;
}

/**
 * 날짜 입력 타입 정의
 */
type DateInput = Date | string | null | undefined;

/**
 * 상수 정의
 */
const ERROR_MESSAGES = {
  REQUIRED_START_DATE: '시작일은 필수입니다',
  REQUIRED_END_DATE: '종료일은 필수입니다',
  INVALID_START_DATE: '유효하지 않은 시작일 형식입니다',
  INVALID_END_DATE: '유효하지 않은 종료일 형식입니다',
  START_AFTER_END: '시작일은 종료일보다 이전이어야 합니다',
} as const;

const WARNING_MESSAGES = {
  EXCEED_100_YEARS: '날짜 범위가 100년을 초과합니다',
} as const;

const CONSTANTS = {
  MILLISECONDS_PER_YEAR: 1000 * 60 * 60 * 24 * 365.25,
  WARNING_THRESHOLD_YEARS: 100,
} as const;

/**
 * null 또는 undefined인지 확인
 */
function isNullOrUndefined(value: unknown): value is null | undefined {
  return value === null || value === undefined;
}

/**
 * 빈 문자열인지 확인
 */
function isEmptyString(value: unknown): boolean {
  return typeof value === 'string' && value.trim() === '';
}

/**
 * 입력값이 유효한지 검증
 * @returns 에러 메시지 또는 null
 */
function validateInput(value: DateInput, fieldName: 'start' | 'end'): string | null {
  if (isNullOrUndefined(value)) {
    return fieldName === 'start'
      ? ERROR_MESSAGES.REQUIRED_START_DATE
      : ERROR_MESSAGES.REQUIRED_END_DATE;
  }

  if (isEmptyString(value)) {
    return fieldName === 'start'
      ? ERROR_MESSAGES.INVALID_START_DATE
      : ERROR_MESSAGES.INVALID_END_DATE;
  }

  return null;
}

/**
 * Date 객체로 변환
 */
function toDateObject(value: Date | string): Date {
  return value instanceof Date ? value : new Date(value);
}

/**
 * 유효한 Date 객체인지 확인
 */
function isValidDate(date: Date): boolean {
  return !isNaN(date.getTime());
}

/**
 * 날짜를 검증하고 Date 객체로 변환
 * @returns Date 객체 또는 에러 메시지
 */
function parseAndValidateDate(value: Date | string, fieldName: 'start' | 'end'): Date | string {
  const dateObj = toDateObject(value);

  if (!isValidDate(dateObj)) {
    return fieldName === 'start'
      ? ERROR_MESSAGES.INVALID_START_DATE
      : ERROR_MESSAGES.INVALID_END_DATE;
  }

  return dateObj;
}

/**
 * 두 날짜 사이의 년수 차이 계산
 */
function calculateYearsDifference(startDate: Date, endDate: Date): number {
  const millisecondsDiff = endDate.getTime() - startDate.getTime();
  return millisecondsDiff / CONSTANTS.MILLISECONDS_PER_YEAR;
}

/**
 * 날짜 범위가 임계값을 초과하는지 확인
 */
function checkLongRangeWarning(startDate: Date, endDate: Date): string | null {
  const yearsDiff = calculateYearsDifference(startDate, endDate);

  if (yearsDiff > CONSTANTS.WARNING_THRESHOLD_YEARS) {
    return WARNING_MESSAGES.EXCEED_100_YEARS;
  }

  return null;
}

/**
 * 두 날짜 사이의 기간이 유효한지 검증하는 함수
 *
 * @param startDate - 시작일 (Date 객체 또는 ISO 8601 문자열)
 * @param endDate - 종료일 (Date 객체 또는 ISO 8601 문자열)
 * @returns 검증 결과 객체
 *
 * @example
 * ```typescript
 * // 유효한 경우
 * validateDateRange('2024-01-01', '2024-12-31')
 * // => { isValid: true }
 *
 * // 무효한 경우
 * validateDateRange('2024-12-31', '2024-01-01')
 * // => { isValid: false, error: '시작일은 종료일보다 이전이어야 합니다' }
 *
 * // 경고가 있는 경우
 * validateDateRange('1900-01-01', '2024-12-31')
 * // => { isValid: true, warning: '날짜 범위가 100년을 초과합니다' }
 * ```
 */
export function validateDateRange(startDate: DateInput, endDate: DateInput): ValidationResult {
  // 1. 입력값 검증 (null, undefined, 빈 문자열)
  const startInputError = validateInput(startDate, 'start');
  if (startInputError) {
    return { isValid: false, error: startInputError };
  }

  const endInputError = validateInput(endDate, 'end');
  if (endInputError) {
    return { isValid: false, error: endInputError };
  }

  // 2. Date 객체로 변환 및 유효성 검증
  const startDateResult = parseAndValidateDate(startDate as Date | string, 'start');
  if (typeof startDateResult === 'string') {
    return { isValid: false, error: startDateResult };
  }

  const endDateResult = parseAndValidateDate(endDate as Date | string, 'end');
  if (typeof endDateResult === 'string') {
    return { isValid: false, error: endDateResult };
  }

  // 3. 날짜 비교 (시작일 <= 종료일)
  if (startDateResult > endDateResult) {
    return { isValid: false, error: ERROR_MESSAGES.START_AFTER_END };
  }

  // 4. 장기간 경고 체크
  const warning = checkLongRangeWarning(startDateResult, endDateResult);
  if (warning) {
    return { isValid: true, warning };
  }

  return { isValid: true };
}
