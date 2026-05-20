import React, { useState } from 'react';
import { Utensils, Award, DollarSign, Clock, CheckCircle } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function DailyMenuScreen({ onNavigate }) {
  const weekdays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  const [selectedDay, setSelectedDay] = useState('Sat');

  // Mock Menu Data per Day
  const menuData = {
    Sat: [
      {
        type: 'Breakfast',
        time: '7:30 AM - 9:00 AM',
        items: 'Paratha (2 pcs), Egg Omelette, Dal Fry',
        price: 25,
        isActive: true,
        image: 'linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%)',
      },
      {
        type: 'Lunch',
        time: '1:00 PM - 2:30 PM',
        items: 'Plain Rice, Beef Curry, Potato Vorta, Lentil Soup',
        price: 65,
        isActive: true,
        image: 'linear-gradient(135deg, #FF9800 0%, #E65100 100%)',
      },
      {
        type: 'Dinner',
        time: '7:30 PM - 9:00 PM',
        items: 'Plain Rice, Fish Curry (Rui), Mixed Vegetable',
        price: 45,
        isActive: false,
        image: 'linear-gradient(135deg, #00BCD4 0%, #006064 100%)',
      },
    ],
    Sun: [
      {
        type: 'Breakfast',
        time: '7:30 AM - 9:00 AM',
        items: 'Khichuri, Egg Curry, Pickle',
        price: 30,
        isActive: true,
        image: 'linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%)',
      },
      {
        type: 'Lunch',
        time: '1:00 PM - 2:30 PM',
        items: 'Plain Rice, Chicken Roast, Thick Lentil Soup',
        price: 55,
        isActive: true,
        image: 'linear-gradient(135deg, #FF9800 0%, #E65100 100%)',
      },
      {
        type: 'Dinner',
        time: '7:30 PM - 9:00 PM',
        items: 'Plain Rice, Egg Curry, Potato Vaji',
        price: 35,
        isActive: true,
        image: 'linear-gradient(135deg, #00BCD4 0%, #006064 100%)',
      },
    ],
    // Copy for other days just in case, or default back to Sat
  };

  const currentMenu = menuData[selectedDay] || menuData['Sat'];

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Top Header */}
      <div className="bg-white px-5 pt-6 pb-2 border-b border-gray-100 z-10">
        <div className="flex justify-between items-center mt-4">
          <div className="text-left">
            <h2 className="text-xl font-bold text-text-primary">Daily Menu</h2>
            <p className="text-xs text-text-secondary">View weekly schedules & pricing</p>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-primary/10 flex items-center justify-center text-primary">
            <Utensils size={20} />
          </div>
        </div>

        {/* Scrollable Weekday Tabs */}
        <div className="flex gap-2.5 overflow-x-auto no-scrollbar py-3.5 mt-1.5">
          {weekdays.map((day) => (
            <button
              key={day}
              onClick={() => setSelectedDay(day)}
              className={`px-4 py-2 rounded-2xl text-xs font-bold transition-all shrink-0 border ${
                selectedDay === day
                  ? 'bg-primary text-white border-primary shadow-md shadow-primary/10'
                  : 'bg-background-soft text-text-secondary border-primary/5 hover:bg-gray-100'
              }`}
            >
              {day}
            </button>
          ))}
        </div>
      </div>

      {/* Menu Cards List */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-5 py-4 space-y-4">
        {currentMenu.map((meal, index) => (
          <div
            key={index}
            className="bg-white rounded-3xl overflow-hidden shadow-sm border border-primary/5 relative flex flex-col hover:shadow-md transition-shadow text-left"
          >
            {/* Colored Header Banner */}
            <div
              className="px-5 py-3 text-white flex justify-between items-center"
              style={{ background: meal.image }}
            >
              <div>
                <span className="text-[10px] font-bold tracking-widest uppercase bg-white/20 px-2 py-0.5 rounded-full">
                  {meal.type}
                </span>
                <div className="flex items-center gap-1 mt-1 text-[10px] text-white/90">
                  <Clock size={11} />
                  <span>{meal.time}</span>
                </div>
              </div>

              {/* Price Tag */}
              <div className="bg-white/20 backdrop-blur-md px-3 py-1 rounded-2xl border border-white/10 font-black text-sm">
                ৳ {meal.price}
              </div>
            </div>

            {/* Content Area */}
            <div className="p-5 flex flex-col justify-between flex-grow gap-3">
              <div>
                <h4 className="font-extrabold text-sm text-text-primary">Featured Items</h4>
                <p className="text-xs text-text-secondary mt-1 leading-relaxed">
                  {meal.items}
                </p>
              </div>

              <div className="h-[1px] bg-gray-100"></div>

              {/* Status footer inside card */}
              <div className="flex justify-between items-center">
                <span className="text-[10px] text-text-secondary font-semibold">
                  Status for tomorrow
                </span>
                {meal.isActive ? (
                  <span className="flex items-center gap-1 text-[10px] text-primary font-bold bg-primary/10 px-2 py-0.5 rounded-full">
                    <CheckCircle size={10} className="stroke-[3]" />
                    <span>Selected</span>
                  </span>
                ) : (
                  <span className="flex items-center gap-1 text-[10px] text-text-secondary font-bold bg-gray-100 px-2 py-0.5 rounded-full">
                    <span>Off</span>
                  </span>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Nav */}
      <BottomNavBar activeTab="menu" onNavigate={onNavigate} />
    </div>
  );
}
