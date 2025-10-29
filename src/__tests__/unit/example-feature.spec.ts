import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('validateDateRange', () => {
  describe('Normal Cases - Basic Behavior', () => {
    it('should return valid when start date is before end date', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid when start date equals end date', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
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

  describe('Input Format Tests', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should accept ISO 8601 strings as input', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-12-31T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should accept mixed input types (Date and string)', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('Error Handling - Null and Undefined', () => {
    it('should return error when start date is null', () => {
      // Arrange
      const startDate = null;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });

    it('should return error when end date is null', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('종료일은 필수입니다');
    });

    it('should return error when start date is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });

    it('should return error when end date is undefined', () => {
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
    it('should return error when start date has invalid format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 시작일 형식입니다');
    });

    it('should return error when end date has invalid format', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = 'not-a-date';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 종료일 형식입니다');
    });

    it('should return error when date string is malformed', () => {
      // Arrange
      const startDate = '2024-13-45';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toContain('유효하지 않은');
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
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid with warning when dates differ by more than 100 years', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('날짜 범위가 100년을 초과합니다');
    });

    it('should handle dates at midnight correctly', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-01-01T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates at end of day correctly', () => {
      // Arrange
      const startDate = '2024-01-01T23:59:59Z';
      const endDate = '2024-01-02T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle leap year dates correctly', () => {
      // Arrange
      const startDate = '2024-02-29';
      const endDate = '2024-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle year boundary correctly', () => {
      // Arrange
      const startDate = '2023-12-31';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle very old dates', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '1900-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle far future dates', () => {
      // Arrange
      const startDate = '2100-01-01';
      const endDate = '2100-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('Edge Cases - Timezone Handling', () => {
    it('should handle different timezone formats', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00+09:00';
      const endDate = '2024-01-01T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일이 종료일보다 이후일 수 없습니다');
    });

    it('should normalize dates to UTC for comparison', () => {
      // Arrange
      const startDate = '2024-01-01T09:00:00+09:00';
      const endDate = '2024-01-01T00:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('Additional Edge Cases', () => {
    it('should handle same date with different time components', () => {
      // Arrange
      const startDate = '2024-01-01T08:00:00Z';
      const endDate = '2024-01-01T18:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates with milliseconds', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00.000Z';
      const endDate = '2024-01-01T00:00:00.001Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle both dates as null', () => {
      // Arrange
      const startDate = null;
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });
  });
});
