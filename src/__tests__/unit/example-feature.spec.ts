import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('validateDateRange', () => {
  describe('Basic Operations', () => {
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
      const startDate = '2024-06-15';
      const endDate = '2024-06-15';

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
      expect(result).toEqual({
        isValid: false,
        error: 'Start date must be before or equal to end date',
      });
    });
  });

  describe('Input Format Validation', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should accept ISO 8601 string format as input', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-12-31T23:59:59Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should accept mixed input types (Date object and ISO string)', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = '2024-12-31T23:59:59Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('Error Handling', () => {
    it('should return error when startDate is null', () => {
      // Arrange
      const startDate = null;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Start date is required',
      });
    });

    it('should return error when endDate is null', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'End date is required',
      });
    });

    it('should return error when startDate is undefined', () => {
      // Arrange
      const startDate = undefined;
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Start date is required',
      });
    });

    it('should return error when endDate is undefined', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = undefined;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'End date is required',
      });
    });

    it('should return error when startDate has invalid format', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Invalid start date format',
      });
    });

    it('should return error when endDate has invalid format', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = 'not-a-date';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Invalid end date format',
      });
    });

    it('should return error when both dates are invalid', () => {
      // Arrange
      const startDate = 'invalid-start';
      const endDate = 'invalid-end';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Invalid start date format',
      });
    });

    it('should handle empty string inputs', () => {
      // Arrange
      const startDate = '';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Invalid start date format',
      });
    });
  });

  describe('Edge Cases', () => {
    it('should return valid when dates are exactly 1 day apart', () => {
      // Arrange
      const startDate = '2024-06-15';
      const endDate = '2024-06-16';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid with warning when dates are more than 100 years apart', () => {
      // Arrange
      const startDate = '1920-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('Date range exceeds 100 years');
    });

    it('should handle dates at year boundaries', () => {
      // Arrange
      const startDate = '2023-12-31T23:59:59';
      const endDate = '2024-01-01T00:00:00';

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

    it('should handle dates with different timezones', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00+09:00';
      const endDate = '2024-01-01T00:00:00-05:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates in distant past', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '1900-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates in distant future', () => {
      // Arrange
      const startDate = '2100-01-01';
      const endDate = '2100-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle same date with different time components', () => {
      // Arrange
      const startDate = '2024-06-15T09:00:00';
      const endDate = '2024-06-15T17:00:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return invalid when same date but start time is after end time', () => {
      // Arrange
      const startDate = '2024-06-15T17:00:00';
      const endDate = '2024-06-15T09:00:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: 'Start date must be before or equal to end date',
      });
    });
  });

  describe('Performance & Boundary Tests', () => {
    it('should execute within acceptable time for valid inputs', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';
      const iterations = 100;

      // Act
      const startTime = performance.now();
      for (let i = 0; i < iterations; i++) {
        validateDateRange(startDate, endDate);
      }
      const endTime = performance.now();
      const averageTime = (endTime - startTime) / iterations;

      // Assert
      expect(averageTime).toBeLessThan(1);
    });
  });
});
