import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('validateDateRange', () => {
  describe('Normal Cases - Basic Operations', () => {
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
      expect(result.error).toBe('시작일이 종료일보다 이후일 수 없습니다');
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

  describe('Error Handling - Null and Undefined', () => {
    it('should return error when startDate is null', () => {
      // Arrange
      const startDate = null;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });

    it('should return error when endDate is null', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일은 필수입니다');
    });

    it('should return error when startDate is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });

    it('should return error when endDate is undefined', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일은 필수입니다');
    });
  });

  describe('Error Handling - Invalid Format', () => {
    it('should return error when startDate has invalid format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('올바른 날짜 형식이 아닙니다');
    });

    it('should return error when endDate has invalid format', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = 'not-a-date';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('올바른 날짜 형식이 아닙니다');
    });

    it('should return error when date is Invalid Date object', () => {
      // Arrange
      const startDate = new Date('invalid');
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('올바른 날짜 형식이 아닙니다');
    });
  });

  describe('Edge Cases - Boundary Values', () => {
    it('should return valid when dates are 1 day apart', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-02';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should return valid with warning when dates are more than 100 years apart', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('날짜 범위가 100년을 초과합니다');
    });

    it('should handle dates at exactly 100 year boundary', () => {
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

    it('should handle year boundary correctly', () => {
      // Arrange
      const startDate = '2023-12-31';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle month boundary correctly', () => {
      // Arrange
      const startDate = '2024-01-31';
      const endDate = '2024-02-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle timestamps with time components', () => {
      // Arrange
      const startDate = '2024-01-01T23:59:59';
      const endDate = '2024-01-02T00:00:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle same date with different time components', () => {
      // Arrange
      const startDate = '2024-01-01T10:00:00';
      const endDate = '2024-01-01T15:00:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });
  });

  describe('Edge Cases - Extreme Values', () => {
    it('should handle very old dates', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '1900-01-02';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle future dates', () => {
      // Arrange
      const startDate = '2100-01-01';
      const endDate = '2100-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
    });

    it('should handle timezone differences in ISO strings', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-01-01T00:00:00+09:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 종료일보다 이후일 수 없습니다');
    });
  });

  describe('Integration Cases', () => {
    it('should validate multiple date ranges in sequence', () => {
      // Arrange
      const ranges = [
        { start: '2024-01-01', end: '2024-12-31' },
        { start: '2023-01-01', end: '2023-06-30' },
        { start: '2025-01-01', end: '2025-12-31' },
      ];

      // Act
      const results = ranges.map((range) => validateDateRange(range.start, range.end));

      // Assert
      results.forEach((result) => {
        expect(result.isValid).toBe(true);
      });
      expect(results).toHaveLength(3);
    });
  });
});
