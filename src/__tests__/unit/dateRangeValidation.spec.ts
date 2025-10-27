import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/dateRangeValidation';

describe('Date Range Validation', () => {
  describe('기본 동작', () => {
    it('should return valid when start date is before end date', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return valid when start date equals end date', () => {
      // Arrange
      const startDate = '2024-06-15';
      const endDate = '2024-06-15';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return invalid when start date is after end date', () => {
      // Arrange
      const startDate = '2024-12-31';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 종료일보다 이전이어야 합니다');
    });
  });

  describe('입력 형식 처리', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-12-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should accept ISO 8601 strings as input', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00Z';
      const endDate = '2024-12-31T23:59:59Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should accept mixed input types (Date and string)', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });
  });

  describe('에러 처리', () => {
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

    it('should return error when both dates are null', () => {
      // Arrange
      const startDate = null;
      const endDate = null;

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 필수입니다');
    });

    it('should return error when start date format is invalid', () => {
      // Arrange
      const startDate = 'invalid-date';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 시작일 형식입니다');
    });

    it('should return error when end date format is invalid', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024/13/32';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 종료일 형식입니다');
    });

    it('should return error when date string is not ISO 8601 format', () => {
      // Arrange
      const startDate = '01/01/2024';
      const endDate = '12/31/2024';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toContain('유효하지 않은');
    });
  });

  describe('경계값 테스트', () => {
    it('should return valid when dates differ by exactly 1 day', () => {
      // Arrange
      const startDate = '2024-06-15';
      const endDate = '2024-06-16';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return valid when dates differ by exactly 1 second', () => {
      // Arrange
      const startDate = '2024-06-15T12:00:00Z';
      const endDate = '2024-06-15T12:00:01Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return valid with warning when dates differ by more than 100 years', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('날짜 범위가 100년을 초과합니다');
    });

    it('should handle leap year dates correctly', () => {
      // Arrange
      const startDate = '2024-02-29';
      const endDate = '2024-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return error when using non-leap year Feb 29', () => {
      // Arrange
      const startDate = '2023-02-29';
      const endDate = '2023-03-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 시작일 형식입니다');
    });

    it('should handle dates at Unix epoch', () => {
      // Arrange
      const startDate = '1970-01-01T00:00:00Z';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should handle far future dates', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2999-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.warning).toBe('날짜 범위가 100년을 초과합니다');
    });

    it('should handle timezone differences correctly', () => {
      // Arrange
      const startDate = '2024-06-15T23:00:00+09:00';
      const endDate = '2024-06-15T15:00:00Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });
  });

  describe('특수 케이스', () => {
    it('should handle millisecond precision', () => {
      // Arrange
      const startDate = '2024-06-15T12:00:00.000Z';
      const endDate = '2024-06-15T12:00:00.001Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should return invalid when dates are reversed by 1 millisecond', () => {
      // Arrange
      const startDate = '2024-06-15T12:00:00.001Z';
      const endDate = '2024-06-15T12:00:00.000Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('시작일은 종료일보다 이전이어야 합니다');
    });

    it('should handle Date objects with time components', () => {
      // Arrange
      const startDate = new Date(2024, 5, 15, 9, 30);
      const endDate = new Date(2024, 5, 15, 17, 30);

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should handle empty string input', () => {
      // Arrange
      const startDate = '';
      const endDate = '2024-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 시작일 형식입니다');
    });

    it('should handle whitespace-only string input', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '   ';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('유효하지 않은 종료일 형식입니다');
    });
  });

  describe('Integration Tests', () => {
    it('should validate multiple date ranges in sequence', () => {
      // Arrange
      const dateRanges = [
        { start: '2024-01-01', end: '2024-01-31' },
        { start: '2024-02-01', end: '2024-02-28' },
        { start: '2024-03-01', end: '2024-03-31' },
      ];

      // Act & Assert
      dateRanges.forEach((range) => {
        const result = validateDateRange(range.start, range.end);
        expect(result.isValid).toBe(true);
      });
    });

    it('should maintain consistency across different input formats', () => {
      // Arrange
      const dateString = '2024-06-15';
      const dateObject = new Date('2024-06-15');
      const endDate = '2024-12-31';

      // Act
      const resultString = validateDateRange(dateString, endDate);
      const resultObject = validateDateRange(dateObject, endDate);

      // Assert
      expect(resultString.isValid).toBe(resultObject.isValid);
      expect(resultString.error).toBe(resultObject.error);
    });

    it('should handle rapid successive calls without side effects', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';
      const iterations = 100;

      // Act
      const results = Array.from({ length: iterations }, () =>
        validateDateRange(startDate, endDate)
      );

      // Assert
      results.forEach((result) => {
        expect(result.isValid).toBe(true);
      });
    });
  });

  describe('Performance Tests', () => {
    it('should execute within acceptable time for valid inputs', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-12-31';
      const startTime = performance.now();

      // Act
      validateDateRange(startDate, endDate);
      const endTime = performance.now();
      const executionTime = endTime - startTime;

      // Assert
      expect(executionTime).toBeLessThan(10);
    });

    it('should handle large batch processing efficiently', () => {
      // Arrange
      const batchSize = 10000;
      const dateRanges = Array.from({ length: batchSize }, (_, i) => ({
        start: `2024-01-${String((i % 28) + 1).padStart(2, '0')}`,
        end: '2024-12-31',
      }));
      const startTime = performance.now();

      // Act
      dateRanges.forEach((range) => {
        validateDateRange(range.start, range.end);
      });
      const endTime = performance.now();
      const executionTime = endTime - startTime;

      // Assert
      expect(executionTime).toBeLessThan(1000);
    });
  });
});
