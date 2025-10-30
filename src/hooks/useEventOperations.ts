import { useSnackbar } from 'notistack';
import { useEffect, useState } from 'react';
import { v4 as uuidv4 } from 'uuid'; // 상단에 추가

import { Event, EventForm } from '../types';
import { generateRecurringDates } from '../utils/scheduleRecurringRule';

export const useEventOperations = (editing: boolean, onSave?: () => void) => {
  const [events, setEvents] = useState<Event[]>([]);
  const { enqueueSnackbar } = useSnackbar();

  const fetchEvents = async () => {
    try {
      const response = await fetch('/api/events');
      if (!response.ok) {
        throw new Error('Failed to fetch events');
      }
      const { events } = await response.json();
      setEvents(events);
    } catch (error) {
      console.error('Error fetching events:', error);
      enqueueSnackbar('이벤트 로딩 실패', { variant: 'error' });
    }
  };

  const saveEvent = async (
    eventData: Event | EventForm,
    options?: { recurringEditAll?: boolean }
  ) => {
    try {
      if (editing && options?.recurringEditAll && eventData.repeat?.id) {
        // 반복 일정 전체 수정
        const response = await fetch(`/api/recurring-events/${eventData.repeat.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(eventData),
        });
        if (!response.ok) throw new Error('Failed to update recurring events');
        await fetchEvents();
        onSave?.();
        enqueueSnackbar('반복 일정 전체가 수정되었습니다.', { variant: 'success' });
        return;
      }

      if (!editing && eventData.repeat.type !== 'none') {
        // endDate가 있으면 개수 계산, 없으면 기본 999
        let count = 999; // 기본값

        if (eventData.repeat.endDate) {
          // 종료일까지 최대 생성 가능한 개수 계산
          const startDate = new Date(eventData.date);
          const endDate = new Date(eventData.repeat.endDate);
          const diffTime = endDate.getTime() - startDate.getTime();
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

          // 반복 타입에 따라 최대 개수 계산
          switch (eventData.repeat.type) {
            case 'daily':
              count = Math.max(0, Math.floor(diffDays / eventData.repeat.interval));
              break;
            case 'weekly':
              count = Math.max(0, Math.floor(diffDays / (7 * eventData.repeat.interval)));
              break;
            case 'monthly':
              count = Math.max(0, Math.floor(diffDays / 30)); // 대략적 계산
              break;
            case 'yearly':
              count = Math.max(0, Math.floor(diffDays / 365)); // 대략적 계산
              break;
          }

          // 안전장치: 최대 1000개로 제한
          count = Math.min(count, 1000);
        }

        // 반복 날짜 생성 (interval만큼 건너뛰면서)
        const recurringDates = generateRecurringDates(
          eventData.date,
          eventData.repeat.type,
          count * eventData.repeat.interval // interval을 count에 곱함
        ).filter((_, index) => index % eventData.repeat.interval === 0); // interval만큼 필터링

        // endDate가 있으면 해당 날짜까지만 필터링
        let filteredDates = recurringDates;
        if (eventData.repeat.endDate) {
          const endDate = new Date(eventData.repeat.endDate);
          filteredDates = recurringDates.filter((date) => new Date(date) <= endDate);
        }
        const repeatId = uuidv4();

        // 각 날짜마다 이벤트 생성

        for (const date of filteredDates) {
          await fetch('/api/events', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              ...eventData,
              date,
              icon: '🔄',
              repeat: {
                ...eventData.repeat,
                id: repeatId, // 모든 반복 이벤트에 동일한 repeat.id 할당
              },
            }),
          });
        }

        await fetchEvents();
        onSave?.();
        enqueueSnackbar(`반복 일정이 추가되었습니다. (${filteredDates.length}개)`, {
          variant: 'success',
        });
        return;
      }

      let response;
      if (editing) {
        response = await fetch(`/api/events/${(eventData as Event).id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(eventData),
        });
      } else {
        response = await fetch('/api/events', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(eventData),
        });
      }

      if (!response.ok) {
        throw new Error('Failed to save event');
      }

      await fetchEvents();
      onSave?.();
      enqueueSnackbar(editing ? '일정이 수정되었습니다.' : '일정이 추가되었습니다.', {
        variant: 'success',
      });
    } catch (error) {
      console.error('Error saving event:', error);
      enqueueSnackbar('일정 저장 실패', { variant: 'error' });
    }
  };

  const deleteEvent = async (id: string) => {
    try {
      const response = await fetch(`/api/events/${id}`, { method: 'DELETE' });

      if (!response.ok) {
        throw new Error('Failed to delete event');
      }

      await fetchEvents();
      enqueueSnackbar('일정이 삭제되었습니다.', { variant: 'info' });
    } catch (error) {
      console.error('Error deleting event:', error);
      enqueueSnackbar('일정 삭제 실패', { variant: 'error' });
    }
  };

  const deleteRecurringEvents = async (repeatId: string) => {
    try {
      const response = await fetch(`/api/recurring-events/${repeatId}`, { method: 'DELETE' });
      if (!response.ok && response.status !== 204) {
        throw new Error('Failed to delete recurring events');
      }
      await fetchEvents();
      enqueueSnackbar('반복 일정 전체가 삭제되었습니다.', { variant: 'info' });
    } catch (error) {
      console.error('Error deleting recurring events:', error);
      enqueueSnackbar('반복 일정 전체 삭제 실패', { variant: 'error' });
    }
  };

  async function init() {
    await fetchEvents();
    enqueueSnackbar('일정 로딩 완료!', { variant: 'info' });
  }

  useEffect(() => {
    init();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { events, fetchEvents, saveEvent, deleteEvent, deleteRecurringEvents };
};
