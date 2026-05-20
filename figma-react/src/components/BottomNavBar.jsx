import React from 'react';
import { Home, CalendarDays, Utensils, MessageSquareText, UserRound } from 'lucide-react';

export default function BottomNavBar({ activeTab, onNavigate }) {
  const tabs = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'meals', label: 'Meals', icon: CalendarDays },
    { id: 'menu', label: 'Menu', icon: Utensils },
    { id: 'activity', label: 'Activity', icon: MessageSquareText },
    { id: 'profile', label: 'Profile', icon: UserRound },
  ];

  return (
    <div className="bg-white border-t border-gray-100 px-3 pb-6 pt-3 flex justify-between items-center shadow-lg rounded-t-[28px] z-30">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => onNavigate(tab.id)}
            className="flex flex-col items-center justify-center flex-1 py-1 relative group"
          >
            <div
              className={`w-12 h-8 rounded-2xl flex items-center justify-center transition-all ${
                isActive
                  ? 'bg-primary text-white shadow-md shadow-primary/20 scale-105'
                  : 'text-text-secondary hover:text-primary hover:bg-primary/5'
              }`}
            >
              <Icon size={20} />
            </div>
            <span
              className={`text-[9px] font-bold mt-1 transition-colors ${
                isActive ? 'text-primary' : 'text-text-secondary'
              }`}
            >
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
