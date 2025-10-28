import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/dateValidation';

describe('validateDateRange', () => {
  describe('기본 동작', () => {
    it('should return valid when start date is before end date', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = new Date('2025-01-10');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid when start date equals end date', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = new Date('2025-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return invalid when start date is after end date', () => {
      // Arrange
      const startDate = new Date('2025-01-10');
      const endDate = new Date('2025-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 종료일보다 이전이어야 합니다',
      });
    });
  });

  describe('ISO 8601 문자열 입력', () => {
    it('should handle ISO 8601 string format for valid date range', () => {
      // Arrange
      const startDate = '2025-01-01';
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle ISO 8601 string format with time information', () => {
      // Arrange
      const startDate = '2025-01-01T09:00:00Z';
      const endDate = '2025-01-01T17:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle mixed input types (Date and string)', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('에러 처리', () => {
    it('should return error when startDate is null', () => {
      // Arrange
      const startDate = null;
      const endDate = new Date('2025-01-10');

      // Act
      const result = validateDateRange(startDate as any, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다',
      });
    });

    it('should return error when endDate is null', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate as any);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다',
      });
    });

    it('should return error when startDate is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = new Date('2025-01-10');

      // Act
      const result = validateDateRange(startDate as any, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다',
      });
    });

    it('should return error when endDate is undefined', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate as any);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다',
      });
    });

    it('should return error when both dates are null', () => {
      // Arrange
      const startDate = null;
      const endDate = null;

      // Act
      const result = validateDateRange(startDate as any, endDate as any);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일과 종료일은 필수입니다',
      });
    });

    it('should return error for invalid date string format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '유효하지 않은 날짜 형식입니다',
      });
    });

    it('should return error for malformed ISO 8601 string', () => {
      // Arrange
      const startDate = '2025/01/01';
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '유효하지 않은 날짜 형식입니다',
      });
    });

    it('should return error for Invalid Date object', () => {
      // Arrange
      const startDate = new Date('invalid');
      const endDate = new Date('2025-01-10');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '유효하지 않은 날짜입니다',
      });
    });
  });

  describe('경계값 테스트', () => {
    it('should return valid for same date with different time zones', () => {
      // Arrange
      const startDate = '2025-01-01T00:00:00+09:00';
      const endDate = '2025-01-01T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid for 1 day difference', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = new Date('2025-01-02');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid with warning for 100+ years difference', () => {
      // Arrange
      const startDate = new Date('1900-01-01');
      const endDate = new Date('2025-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: true,
        warning: '날짜 범위가 100년을 초과합니다',
      });
    });

    it('should handle leap year date (Feb 29)', () => {
      // Arrange
      const startDate = new Date('2024-02-29');
      const endDate = new Date('2024-03-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return error for Feb 29 in non-leap year', () => {
      // Arrange
      const startDate = '2025-02-29';
      const endDate = '2025-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '유효하지 않은 날짜입니다',
      });
    });

    it('should handle year boundary crossing (year-end to new year)', () => {
      // Arrange
      const startDate = new Date('2024-12-31');
      const endDate = new Date('2025-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle minimum JavaScript date', () => {
      // Arrange
      const startDate = new Date(-8640000000000000);
      const endDate = new Date('2025-01-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBeDefined();
    });

    it('should handle maximum JavaScript date', () => {
      // Arrange
      const startDate = new Date('2025-01-01');
      const endDate = new Date(8640000000000000);

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBeDefined();
    });

    it('should handle midnight edge case', () => {
      // Arrange
      const startDate = '2025-01-01T00:00:00';
      const endDate = '2025-01-01T23:59:59';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle month boundary (Jan 31 to Feb 1)', () => {
      // Arrange
      const startDate = new Date('2025-01-31');
      const endDate = new Date('2025-02-01');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle empty string inputs', () => {
      // Arrange
      const startDate = '';
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '날짜는 필수입니다',
      });
    });

    it('should handle whitespace-only string inputs', () => {
      // Arrange
      const startDate = '   ';
      const endDate = '2025-01-10';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '유효하지 않은 날짜 형식입니다',
      });
    });

    it('should handle date with milliseconds precision', () => {
      // Arrange
      const startDate = '2025-01-01T12:00:00.123Z';
      const endDate = '2025-01-01T12:00:00.456Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('통합 테스트', () => {
    it('should validate event date range in calendar application', () => {
      // Arrange
      const event = {
        name: 'Team Meeting',
        startDate: new Date('2025-01-15T10:00:00'),
        endDate: new Date('2025-01-15T11:00:00'),
      };

      // Act
      const result = validateDateRange(event.startDate, event.endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should work with form validation in React component', () => {
      // Arrange
      const formData = {
        startDate: '2025-01-01',
        endDate: '2025-01-10',
      };

      // Act
      const result = validateDateRange(formData.startDate, formData.endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle consecutive validation calls with different inputs', () => {
      // Arrange
      const events = [
        { start: '2025-01-01', end: '2025-01-05' },
        { start: '2025-01-10', end: '2025-01-15' },
        { start: '2025-01-20', end: '2025-01-25' },
      ];

      // Act
      const results = events.map((event) => validateDateRange(event.start, event.end));

      // Assert
      expect(results.every((r) => r.isValid)).toBe(true);
      expect(results).toHaveLength(3);
    });
  });
});
