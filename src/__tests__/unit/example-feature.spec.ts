import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('Date Range Validator', () => {
  describe('Normal Cases - Basic Operation', () => {
    it('should return valid when start date is before end date', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should return valid when start date equals end date', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should return invalid when start date is after end date', () => {
      // Arrange
      const startDate = '2024-12-31';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 종료일보다 이후입니다');
    });
  });

  describe('Input Format Cases', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should accept ISO 8601 strings as input', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-12-31T23:59:59Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should accept mixed Date object and ISO string', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });
  });

  describe('Error Cases - Null and Undefined', () => {
    it('should return error when start date is null', () => {
      // Arrange
      const startDate = null;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 유효하지 않습니다');
    });

    it('should return error when end date is null', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일이 유효하지 않습니다');
    });

    it('should return error when start date is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 유효하지 않습니다');
    });

    it('should return error when end date is undefined', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일이 유효하지 않습니다');
    });
  });

  describe('Error Cases - Invalid Format', () => {
    it('should return error when start date has invalid format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일 형식이 올바르지 않습니다');
    });

    it('should return error when end date has invalid format', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = 'not-a-date';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일 형식이 올바르지 않습니다');
    });

    it('should return error when both dates are invalid', () => {
      // Arrange
      const startDate = null;
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 유효하지 않습니다');
    });
  });

  describe('Edge Cases - Boundary Values', () => {
    it('should return valid when dates differ by exactly 1 day', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-02';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should return valid with warning when dates differ by over 100 years', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('날짜 범위가 100년을 초과합니다');
    });

    it('should return valid when dates are exactly 100 years apart', () => {
      // Arrange
      const startDate = '1924-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBeUndefined();
    });

    it('should handle leap year dates correctly', () => {
      // Arrange
      const startDate = '2024-02-29';
      const endDate = '2024-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should return error for invalid leap year date', () => {
      // Arrange
      const startDate = '2023-02-29';
      const endDate = '2023-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일 형식이 올바르지 않습니다');
    });

    it('should handle dates at year boundaries', () => {
      // Arrange
      const startDate = '2023-12-31T23:59:59';
      const endDate = '2024-01-01T00:00:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle very old dates', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '1900-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle far future dates', () => {
      // Arrange
      const startDate = '2100-01-01';
      const endDate = '2100-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle same date with different time zones', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00+09:00';
      const endDate = '2024-01-01T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 종료일보다 이후입니다');
    });
  });

  describe('Edge Cases - Special Inputs', () => {
    it('should handle empty string input', () => {
      // Arrange
      const startDate = '';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일 형식이 올바르지 않습니다');
    });

    it('should handle numeric timestamp input', () => {
      // Arrange
      const startDate = 1704067200000;
      const endDate = 1735689599000;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일 형식이 올바르지 않습니다');
    });

    it('should handle Invalid Date object', () => {
      // Arrange
      const startDate = new Date('invalid');
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일 형식이 올바르지 않습니다');
    });
  });
});
