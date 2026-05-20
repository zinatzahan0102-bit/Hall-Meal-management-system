import React, { useState } from 'react';
import { User, Bell, Flame, Calendar, DollarSign, Award, Clock, ChevronRight, CheckCircle2, XCircle } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function StudentHomeScreen({ onNavigate, user }) {
  const [isNextDayMealActive, setIsNextDayMealActive] = useState(true);

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Top Header Panel */}
      <div className="bg-gradient-to-br from-primary to-primary-dark p-6 rounded-b-[32px] text-white shadow-lg relative overflow-hidden">
        {/* Glow rings */}
        <div className="absolute right-[-40px] top-[-40px] w-36 h-36 rounded-full bg-white/10 blur-xl"></div>
        
        {/* Navigation Bar Header */}
        <div className="flex justify-between items-center mt-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-white/20 border border-white/30 flex items-center justify-center font-bold text-white text-lg">
              {user.name ? user.name.charAt(0) : 'S'}
            </div>
            <div className="text-left">
              <p className="text-[10px] text-primary-light font-medium uppercase tracking-wider">Welcome back</p>
              <h3 className="font-bold text-base leading-tight">{user.name || 'Student Name'}</h3>
            </div>
          </div>
          <button className="w-9 h-9 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/25 transition-all">
            <Bell size={18} />
          </button>
        </div>

        {/* Room ID Sub-badge */}
        <div className="flex gap-4 mt-5 bg-white/10 p-3 rounded-2xl border border-white/5 backdrop-blur-sm text-xs font-semibold">
          <div className="flex-1 text-left border-r border-white/10">
            <p className="text-[9px] text-primary-light uppercase">Room No</p>
            <p className="text-sm font-bold mt-0.5">{user.room || '402-B'}</p>
          </div>
          <div className="flex-1 text-left">
            <p className="text-[9px] text-primary-light uppercase">Student ID</p>
            <p className="text-sm font-bold mt-0.5">{user.id || '20210804'}</p>
          </div>
        </div>
      </div>

      {/* Main Dashboard Content */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-5 py-4 space-y-4">
        {/* Next Day Meal Status Banner */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-primary/5">
          <div className="flex justify-between items-center">
            <div className="text-left">
              <span className="text-[10px] bg-accent/10 text-accent-dark font-bold px-2 py-0.5 rounded-full uppercase tracking-wider">
                Tomorrow's Meals
              </span>
              <h4 className="font-bold text-sm text-text-primary mt-1">Status: {isNextDayMealActive ? 'Active' : 'Off'}</h4>
              <p className="text-[11px] text-text-secondary">Breakfast, Lunch, & Dinner status</p>
            </div>
            
            {/* iOS Style Switcher */}
            <button
              onClick={() => setIsNextDayMealActive(!isNextDayMealActive)}
              className={`w-14 h-8 rounded-full p-1 transition-all duration-300 ${
                isNextDayMealActive ? 'bg-primary' : 'bg-gray-300'
              }`}
            >
              <div
                className={`w-6 h-6 rounded-full bg-white shadow-md transform transition-all duration-300 ${
                  isNextDayMealActive ? 'translate-x-6' : 'translate-x-0'
                }`}
              ></div>
            </button>
          </div>

          <div className="h-[1px] bg-gray-100 my-3"></div>

          {/* Time Limit Countdown Notification */}
          <div className="flex items-center gap-2 text-xs text-text-secondary">
            <Clock size={14} className="text-accent-dark" />
            <span>Cut-off timer: <span className="font-bold text-danger">4 hours left</span> to change</span>
          </div>
        </div>

        {/* 2x2 Statistics Grid */}
        <div className="grid grid-cols-2 gap-3.5">
          {/* Card 1: Total Meals */}
          <div className="bg-white p-4 rounded-3xl shadow-sm border border-primary/5 flex flex-col justify-between text-left">
            <div className="w-9 h-9 rounded-2xl bg-primary/10 flex items-center justify-center text-primary mb-3">
              <Flame size={18} />
            </div>
            <div>
              <p className="text-[11px] font-semibold text-text-secondary">Total Meals Taken</p>
              <p className="text-2xl font-extrabold text-text-primary mt-0.5">48</p>
            </div>
          </div>

          {/* Card 2: Active Days */}
          <div className="bg-white p-4 rounded-3xl shadow-sm border border-primary/5 flex flex-col justify-between text-left">
            <div className="w-9 h-9 rounded-2xl bg-accent/15 flex items-center justify-center text-accent-dark mb-3">
              <Calendar size={18} />
            </div>
            <div>
              <p className="text-[11px] font-semibold text-text-secondary">Active Days Rem.</p>
              <p className="text-2xl font-extrabold text-text-primary mt-0.5">12</p>
            </div>
          </div>

          {/* Card 3: Monthly Bill */}
          <div className="bg-white p-4 rounded-3xl shadow-sm border border-primary/5 flex flex-col justify-between text-left">
            <div className="w-9 h-9 rounded-2xl bg-primary/10 flex items-center justify-center text-primary mb-3">
              <DollarSign size={18} />
            </div>
            <div>
              <p className="text-[11px] font-semibold text-text-secondary">Monthly Bill</p>
              <p className="text-2xl font-extrabold text-text-primary mt-0.5">৳ 1,440</p>
            </div>
          </div>

          {/* Card 4: Feedbacks */}
          <div className="bg-white p-4 rounded-3xl shadow-sm border border-primary/5 flex flex-col justify-between text-left">
            <div className="w-9 h-9 rounded-2xl bg-danger/10 flex items-center justify-center text-danger mb-3">
              <Award size={18} />
            </div>
            <div>
              <p className="text-[11px] font-semibold text-text-secondary">Active Requests</p>
              <p className="text-2xl font-extrabold text-text-primary mt-0.5">1</p>
            </div>
          </div>
        </div>

        {/* Quick Menu Preview */}
        <div
          onClick={() => onNavigate('menu')}
          className="bg-white rounded-3xl p-4 shadow-sm border border-primary/5 flex justify-between items-center cursor-pointer hover:bg-white/70 transition-all text-left"
        >
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-primary/5 flex items-center justify-center text-primary">
              <Calendar size={20} />
            </div>
            <div>
              <h5 className="font-bold text-xs text-text-primary">Today's Menu</h5>
              <p className="text-[10px] text-text-secondary">Lunch: Beef Curry & Rice, Dinner: Fish Curry</p>
            </div>
          </div>
          <ChevronRight size={16} className="text-text-secondary" />
        </div>
      </div>

      {/* Reusable Bottom Navigation */}
      <BottomNavBar activeTab="home" onNavigate={onNavigate} />
    </div>
  );
}
