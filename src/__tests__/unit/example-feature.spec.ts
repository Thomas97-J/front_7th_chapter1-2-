import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('validateDateRange', () => {
  describe('기본 동작', () => {
    it('should return valid when start date is before end date', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid when start date equals end date', () => {
      // Arrange
      const startDate = new Date('2024-06-15');
      const endDate = new Date('2024-06-15');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return invalid when start date is after end date', () => {
      // Arrange
      const startDate = new Date('2024-12-31');
      const endDate = new Date('2024-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 종료일보다 이후일 수 없습니다',
      });
    });
  });

  describe('입력 형식', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-03-01');
      const endDate = new Date('2024-03-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should accept ISO 8601 strings as input', () => {
      // Arrange
      const startDate = '2024-01-15';
      const endDate = '2024-06-15';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should accept mixed input types (Date and ISO string)', () => {
      // Arrange
      const startDate = new Date('2024-02-01');
      const endDate = '2024-08-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });
  });

  describe('에러 처리 - null/undefined', () => {
    it('should return error when start date is null', () => {
      // Arrange
      const startDate = null;
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다',
      });
    });

    it('should return error when end date is null', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다',
      });
    });

    it('should return error when start date is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다',
      });
    });

    it('should return error when end date is undefined', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다',
      });
    });
  });

  describe('에러 처리 - 잘못된 형식', () => {
    it('should return error when start date has invalid format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });

    it('should return error when end date has invalid format', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = '2024-13-45';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일 형식이 올바르지 않습니다',
      });
    });

    it('should return error when date string is empty', () => {
      // Arrange
      const startDate = '';
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });
  });

  describe('경계값 - 날짜 차이', () => {
    it('should return valid when dates differ by exactly 1 day', () => {
      // Arrange
      const startDate = new Date('2024-06-15');
      const endDate = new Date('2024-06-16');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid with warning when dates differ by more than 100 years', () => {
      // Arrange
      const startDate = new Date('1900-01-01');
      const endDate = new Date('2024-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: true,
        warning: '날짜 범위가 100년을 초과합니다',
      });
    });

    it('should return valid when dates differ by exactly 100 years', () => {
      // Arrange
      const startDate = new Date('1924-01-01');
      const endDate = new Date('2024-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates at year boundary (December 31 to January 1)', () => {
      // Arrange
      const startDate = new Date('2023-12-31');
      const endDate = new Date('2024-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle leap year dates correctly', () => {
      // Arrange
      const startDate = new Date('2024-02-28');
      const endDate = new Date('2024-02-29');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('엣지 케이스 - 시간 및 타임존', () => {
    it('should compare dates by day only, ignoring time', () => {
      // Arrange
      const startDate = new Date('2024-01-01T09:00:00');
      const endDate = new Date('2024-01-01T23:59:59');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle ISO strings with timezone information', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-12-31T23:59:59Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });
  });

  describe('엣지 케이스 - Invalid Date', () => {
    it('should return error when passed Invalid Date object', () => {
      // Arrange
      const startDate = new Date('invalid');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });

    it('should return error when end date is Invalid Date object', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('not-a-date');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일 형식이 올바르지 않습니다',
      });
    });
  });

  describe('엣지 케이스 - 비정상 타입', () => {
    it('should return error when passed number type', () => {
      // Arrange
      const startDate = 20240101 as any;
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });

    it('should return error when passed object type', () => {
      // Arrange
      const startDate = { year: 2024, month: 1, day: 1 } as any;
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });

    it('should return error when passed array type', () => {
      // Arrange
      const startDate = [2024, 1, 1] as any;
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다',
      });
    });
  });

  describe('엣지 케이스 - 극단적 날짜', () => {
    it('should handle very old dates (historical dates)', () => {
      // Arrange
      const startDate = new Date('1800-01-01');
      const endDate = new Date('1850-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle far future dates', () => {
      // Arrange
      const startDate = new Date('2100-01-01');
      const endDate = new Date('2200-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });
  });
});
