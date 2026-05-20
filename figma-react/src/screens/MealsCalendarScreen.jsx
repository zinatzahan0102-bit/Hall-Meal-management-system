import React, { useState } from 'react';
import { CalendarDays, AlertTriangle, ArrowRight, ToggleLeft, ToggleRight, Check, X } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function MealsCalendarScreen({ onNavigate }) {
  // Mock calendar days: 1 to 30.
  // We store the state of active/inactive for each day.
  const [mealStatuses, setMealStatuses] = useState(
    Array.from({ length: 30 }, (_, i) => ({
      day: i + 1,
      isActive: i % 7 !== 4 && i % 7 !== 5, // make some weekends off by default
      isSelected: false,
    }))
  );

  const [isUpdating, setIsUpdating] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');

  const toggleDaySelection = (dayNum) => {
    setMealStatuses(
      mealStatuses.map((item) =>
        item.day === dayNum ? { ...item, isSelected: !item.isSelected } : item
      )
    );
  };

  const selectAll = () => {
    setMealStatuses(mealStatuses.map((item) => ({ ...item, isSelected: true })));
  };

  const clearSelection = () => {
    setMealStatuses(mealStatuses.map((item) => ({ ...item, isSelected: false })));
  };

  const applyStatusChange = (status) => {
    setIsUpdating(true);
    setSuccessMsg('');
    setTimeout(() => {
      setMealStatuses(
        mealStatuses.map((item) =>
          item.isSelected ? { ...item, isActive: status, isSelected: false } : item
        )
      );
      setIsUpdating(false);
      setSuccessMsg(`Meals successfully turned ${status ? 'ON' : 'OFF'}!`);
      setTimeout(() => setSuccessMsg(''), 2000);
    }, 800);
  };

  const selectedCount = mealStatuses.filter((item) => item.isSelected).length;

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Header */}
      <div className="bg-white px-5 pt-6 pb-4 border-b border-gray-100 flex justify-between items-center z-10">
        <div className="text-left mt-4">
          <h2 className="text-xl font-bold text-text-primary">Meals Calendar</h2>
          <p className="text-xs text-text-secondary">Tap days to toggle status or bulk update</p>
        </div>
        <div className="w-10 h-10 rounded-2xl bg-primary/10 flex items-center justify-center text-primary mt-4">
          <CalendarDays size={20} />
        </div>
      </div>

      {/* Content Area */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-4 py-3 space-y-4">
        {/* Success Alert Banner */}
        {successMsg && (
          <div className="p-3 text-xs bg-primary/10 text-primary border border-primary/25 rounded-2xl flex items-center gap-2 font-bold animate-pulse">
            <Check size={16} />
            <span>{successMsg}</span>
          </div>
        )}

        {/* Legend Panel */}
        <div className="bg-white rounded-2xl p-3 shadow-sm border border-primary/5 flex justify-around text-xs font-semibold text-text-secondary">
          <div className="flex items-center gap-1.5">
            <div className="w-3.5 h-3.5 rounded-full bg-primary/15 border border-primary/30 flex items-center justify-center text-primary">
              <Check size={10} />
            </div>
            <span>Meal On</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-3.5 h-3.5 rounded-full bg-danger/15 border border-danger/30 flex items-center justify-center text-danger">
              <X size={10} />
            </div>
            <span>Meal Off</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-3.5 h-3.5 rounded-full bg-accent/20 border border-accent/40"></div>
            <span>Selected</span>
          </div>
        </div>

        {/* Calendar Grid Container */}
        <div className="bg-white rounded-3xl p-4 shadow-sm border border-primary/5">
          {/* Calendar Header Row */}
          <div className="flex justify-between items-center mb-4">
            <h4 className="font-bold text-sm text-text-primary">May 2026</h4>
            <div className="flex gap-2">
              <button
                onClick={selectAll}
                className="text-[10px] font-bold text-primary bg-primary/10 px-2.5 py-1 rounded-xl hover:bg-primary/25"
              >
                Select All
              </button>
              <button
                onClick={clearSelection}
                className="text-[10px] font-bold text-text-secondary bg-gray-100 px-2.5 py-1 rounded-xl hover:bg-gray-200"
              >
                Clear
              </button>
            </div>
          </div>

          {/* Weekday Labels */}
          <div className="grid grid-cols-7 gap-1 text-center text-[10px] font-extrabold text-text-secondary mb-2 uppercase tracking-wide">
            <span>S</span><span>M</span><span>T</span><span>W</span><span>T</span><span>F</span><span>S</span>
          </div>

          {/* Calendar Days */}
          <div className="grid grid-cols-7 gap-2">
            {/* Empty offset spacer */}
            <div className="aspect-square bg-transparent"></div>
            <div className="aspect-square bg-transparent"></div>
            
            {mealStatuses.map((item) => {
              const { day, isActive, isSelected } = item;
              return (
                <button
                  key={day}
                  onClick={() => toggleDaySelection(day)}
                  className={`aspect-square rounded-2xl flex flex-col items-center justify-between p-1.5 relative border transition-all ${
                    isSelected
                      ? 'bg-accent/15 border-accent shadow-sm shadow-accent/10 scale-95'
                      : isActive
                      ? 'bg-primary/5 border-primary/10 text-primary hover:bg-primary/10'
                      : 'bg-danger/5 border-danger/10 text-danger hover:bg-danger/10'
                  }`}
                >
                  <span className="text-xs font-bold">{day}</span>
                  {isActive ? (
                    <Check size={11} className="stroke-[3] opacity-80" />
                  ) : (
                    <X size={11} className="stroke-[3] opacity-80" />
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Selected Days Bottom Bar Form */}
        {selectedCount > 0 && (
          <div className="bg-white rounded-3xl p-4 border border-accent/20 shadow-md animate-slide-up text-left">
            <h5 className="font-extrabold text-xs text-text-primary">
              Bulk Edit Selected ({selectedCount} {selectedCount === 1 ? 'day' : 'days'})
            </h5>
            <p className="text-[10px] text-text-secondary mt-0.5">Toggle meal status for selected dates</p>
            
            <div className="grid grid-cols-2 gap-3 mt-3.5">
              <button
                onClick={() => applyStatusChange(true)}
                disabled={isUpdating}
                className="py-2.5 rounded-xl bg-primary text-white font-bold text-xs hover:bg-primary-dark transition-all flex items-center justify-center gap-1.5 shadow-md shadow-primary/10"
              >
                {isUpdating ? (
                  <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                ) : (
                  <>
                    <Check size={14} className="stroke-[3]" />
                    <span>Turn ON</span>
                  </>
                )}
              </button>
              
              <button
                onClick={() => applyStatusChange(false)}
                disabled={isUpdating}
                className="py-2.5 rounded-xl bg-danger text-white font-bold text-xs hover:bg-danger-dark transition-all flex items-center justify-center gap-1.5 shadow-md shadow-danger/10"
              >
                {isUpdating ? (
                  <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                ) : (
                  <>
                    <X size={14} className="stroke-[3]" />
                    <span>Turn OFF</span>
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Nav */}
      <BottomNavBar activeTab="meals" onNavigate={onNavigate} />
    </div>
  );
}
