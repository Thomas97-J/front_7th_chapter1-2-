import { describe, it, expect } from 'vitest';

import { validateDateRange } from '../../utils/validateDateRange';

describe('validateDateRange', () => {
  describe('기본 동작', () => {
    it('should return valid when startDate is before endDate', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid when startDate equals endDate', () => {
      // Arrange
      const startDate = '2024-01-15';
      const endDate = '2024-01-15';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return invalid with error when startDate is after endDate', () => {
      // Arrange
      const startDate = '2024-02-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 종료일보다 이전이어야 합니다.',
      });
    });
  });

  describe('입력 타입 검증', () => {
    it('should accept Date objects as input', () => {
      // Arrange
      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-01-31');

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should accept ISO 8601 strings as input', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00.000Z';
      const endDate = '2024-01-31T23:59:59.999Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('에러 처리', () => {
    it('should return invalid when startDate is null', () => {
      // Arrange & Act
      const result = validateDateRange(null, '2024-01-31');

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다.',
      });
    });

    it('should return invalid when endDate is null', () => {
      // Arrange & Act
      const result = validateDateRange('2024-01-01', null);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다.',
      });
    });

    it('should return invalid when startDate is undefined', () => {
      // Arrange & Act
      const result = validateDateRange(undefined, '2024-01-31');

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일은 필수입니다.',
      });
    });

    it('should return invalid when endDate is undefined', () => {
      // Arrange & Act
      const result = validateDateRange('2024-01-01', undefined);

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일은 필수입니다.',
      });
    });

    it('should return invalid when startDate format is invalid', () => {
      // Arrange & Act
      const result = validateDateRange('invalid-date', '2024-01-31');

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다.',
      });
    });

    it('should return invalid when endDate format is invalid', () => {
      // Arrange & Act
      const result = validateDateRange('2024-01-01', 'not-a-date');

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '종료일 형식이 올바르지 않습니다.',
      });
    });

    it('should return invalid when startDate is Invalid Date object', () => {
      // Arrange
      const invalidDate = new Date('invalid');

      // Act
      const result = validateDateRange(invalidDate, '2024-01-31');

      // Assert
      expect(result).toEqual({
        isValid: false,
        error: '시작일 형식이 올바르지 않습니다.',
      });
    });
  });

  describe('엣지 케이스', () => {
    it('should return valid when dates are 1 day apart', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2024-01-02';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid when dates are 1 second apart', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00';
      const endDate = '2024-01-01T00:00:01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should return valid with warning when dates are more than 100 years apart', () => {
      // Arrange
      const startDate = '1900-01-01';
      const endDate = '2024-01-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: true,
        warning: '기간이 100년을 초과합니다.',
      });
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

    it('should handle month boundary correctly', () => {
      // Arrange
      const startDate = '2024-01-31';
      const endDate = '2024-02-01';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle timezone differences correctly', () => {
      // Arrange
      const startDate = '2024-01-01T23:00:00+09:00';
      const endDate = '2024-01-02T01:00:00+09:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle dates at the edge of time (year 1970)', () => {
      // Arrange
      const startDate = '1970-01-01';
      const endDate = '1970-01-02';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle far future dates', () => {
      // Arrange
      const startDate = '2024-01-01';
      const endDate = '2099-12-31';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({
        isValid: true,
        warning: '기간이 100년을 초과합니다.',
      });
    });

    it('should handle midnight edge case', () => {
      // Arrange
      const startDate = '2024-01-01T00:00:00.000Z';
      const endDate = '2024-01-01T23:59:59.999Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should handle millisecond precision', () => {
      // Arrange
      const startDate = '2024-01-01T12:00:00.001Z';
      const endDate = '2024-01-01T12:00:00.002Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });

  describe('통합 테스트', () => {
    it('should work with form input dates', () => {
      // Arrange - HTML input[type="date"] format
      const startDate = '2024-01-15';
      const endDate = '2024-01-20';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should work with datetime-local input', () => {
      // Arrange - HTML input[type="datetime-local"] format
      const startDate = '2024-01-15T10:00';
      const endDate = '2024-01-15T14:00';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });

    it('should work with API response dates', () => {
      // Arrange - ISO 8601 from API
      const startDate = '2024-01-01T00:00:00.000Z';
      const endDate = '2024-12-31T23:59:59.999Z';

      // Act
      const result = validateDateRange(startDate, endDate);

      // Assert
      expect(result).toEqual({ isValid: true });
    });
  });
});
