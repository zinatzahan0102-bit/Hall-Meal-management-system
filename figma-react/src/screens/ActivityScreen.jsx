import React, { useState } from 'react';
import { MessageSquareText, Star, ShieldAlert, Award, Calendar, Check, MessageSquareCode, Plus } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function ActivityScreen({ onNavigate }) {
  const [activeSubTab, setActiveSubTab] = useState('history');

  // Mock Meal History
  const historyData = [
    { date: 'May 18, 2026', breakfast: true, lunch: true, dinner: true, cost: 135 },
    { date: 'May 17, 2026', breakfast: true, lunch: true, dinner: false, cost: 90 },
    { date: 'May 16, 2026', breakfast: true, lunch: false, dinner: true, cost: 70 },
    { date: 'May 15, 2026', breakfast: false, lunch: true, dinner: true, cost: 110 },
  ];

  // Mock Reviews
  const reviewsData = [
    { id: 1, author: 'Sajid Islam', rating: 5, comment: 'Beef curry today was absolutely amazing! Great quality.', date: 'Today' },
    { id: 2, author: 'Sadia Rahman', rating: 4, comment: 'Breakfast paratha was soft. Dal could be warmer.', date: 'Yesterday' },
  ];

  // Mock Complaints
  const complaintsData = [
    { id: 'CMP-202', type: 'Service', status: 'Resolved', date: 'May 14', desc: 'Water filter near the dining table was empty during dinner time.', reply: 'The filter has been refilled and a daily check schedule is placed.' },
    { id: 'CMP-203', type: 'Food Quality', status: 'Pending', date: 'May 18', desc: 'Rice was undercooked in lunch today.', reply: null },
  ];

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Header & Sub-Tabs */}
      <div className="bg-white px-5 pt-6 border-b border-gray-100 z-10">
        <div className="flex justify-between items-center mt-4">
          <div className="text-left">
            <h2 className="text-xl font-bold text-text-primary">Activity & Logs</h2>
            <p className="text-xs text-text-secondary">Track meals, ratings, & complaints</p>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-primary/10 flex items-center justify-center text-primary">
            <MessageSquareText size={20} />
          </div>
        </div>

        {/* Sub-Tab Navigation Bar */}
        <div className="flex border-b border-gray-100 mt-4 text-xs font-bold">
          <button
            onClick={() => setActiveSubTab('history')}
            className={`flex-1 pb-3 text-center transition-all border-b-2 ${
              activeSubTab === 'history' ? 'border-primary text-primary' : 'border-transparent text-text-secondary'
            }`}
          >
            History
          </button>
          <button
            onClick={() => setActiveSubTab('reviews')}
            className={`flex-1 pb-3 text-center transition-all border-b-2 ${
              activeSubTab === 'reviews' ? 'border-primary text-primary' : 'border-transparent text-text-secondary'
            }`}
          >
            Reviews
          </button>
          <button
            onClick={() => setActiveSubTab('complaints')}
            className={`flex-1 pb-3 text-center transition-all border-b-2 ${
              activeSubTab === 'complaints' ? 'border-primary text-primary' : 'border-transparent text-text-secondary'
            }`}
          >
            Complaints
          </button>
        </div>
      </div>

      {/* Tab Contents Area */}
      <div className="flex-grow overflow-y-auto no-scrollbar px-5 py-4">
        {/* TAB 1: MEAL HISTORY */}
        {activeSubTab === 'history' && (
          <div className="space-y-3.5">
            {historyData.map((item, idx) => (
              <div key={idx} className="bg-white rounded-2xl p-4 shadow-sm border border-primary/5 flex justify-between items-center text-left">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <Calendar size={14} className="text-text-secondary" />
                    <span className="font-extrabold text-xs text-text-primary">{item.date}</span>
                  </div>
                  <div className="flex gap-2.5 mt-1 text-[10px] font-bold">
                    <span className={`px-2 py-0.5 rounded-full ${item.breakfast ? 'bg-primary/10 text-primary' : 'bg-gray-100 text-gray-400'}`}>B</span>
                    <span className={`px-2 py-0.5 rounded-full ${item.lunch ? 'bg-primary/10 text-primary' : 'bg-gray-100 text-gray-400'}`}>L</span>
                    <span className={`px-2 py-0.5 rounded-full ${item.dinner ? 'bg-primary/10 text-primary' : 'bg-gray-100 text-gray-400'}`}>D</span>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-[10px] text-text-secondary font-semibold">Cost</p>
                  <p className="font-black text-sm text-text-primary">৳ {item.cost}</p>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* TAB 2: REVIEWS */}
        {activeSubTab === 'reviews' && (
          <div className="space-y-3.5">
            {reviewsData.map((review) => (
              <div key={review.id} className="bg-white rounded-2xl p-4 shadow-sm border border-primary/5 text-left space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-xs font-extrabold text-text-primary">{review.author}</span>
                  <span className="text-[9px] text-text-secondary font-medium">{review.date}</span>
                </div>
                <div className="flex gap-0.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star
                      key={i}
                      size={12}
                      className={i < review.rating ? 'fill-accent stroke-accent' : 'stroke-gray-300'}
                    />
                  ))}
                </div>
                <p className="text-xs text-text-secondary leading-relaxed">{review.comment}</p>
              </div>
            ))}

            {/* Quick Link to write a review */}
            <div className="mt-4 p-4 rounded-2xl bg-primary/5 border border-primary/10 text-center">
              <p className="text-xs font-semibold text-text-primary">How was your meal today?</p>
              <button
                onClick={() => onNavigate('complaint')} // Or a custom complaint/feedback form
                className="mt-2.5 inline-flex items-center gap-1 bg-primary text-white font-bold text-xs px-3.5 py-1.5 rounded-xl hover:bg-primary-dark shadow-md"
              >
                <span>Write Review</span>
              </button>
            </div>
          </div>
        )}

        {/* TAB 3: COMPLAINTS */}
        {activeSubTab === 'complaints' && (
          <div className="space-y-3.5">
            {/* Create new complaint floating action link */}
            <div className="flex justify-between items-center mb-1">
              <span className="text-[11px] text-text-secondary font-bold">Logged Issues</span>
              <button
                onClick={() => onNavigate('complaint')}
                className="flex items-center gap-1 text-[10px] font-bold text-primary bg-primary/10 px-2.5 py-1 rounded-xl hover:bg-primary/20"
              >
                <Plus size={12} />
                <span>File Issue</span>
              </button>
            </div>

            {complaintsData.map((comp) => (
              <div key={comp.id} className="bg-white rounded-2xl p-4 shadow-sm border border-primary/5 text-left space-y-2.5">
                <div className="flex justify-between items-center">
                  <div className="flex items-center gap-1.5">
                    <span className="text-[10px] font-bold text-text-primary">{comp.id}</span>
                    <span className="text-[9px] font-semibold text-text-secondary bg-gray-100 px-2 py-0.5 rounded-full">{comp.type}</span>
                  </div>
                  <span
                    className={`text-[9px] font-black px-2 py-0.5 rounded-full uppercase tracking-wider ${
                      comp.status === 'Resolved' ? 'bg-primary/15 text-primary' : 'bg-accent/15 text-accent-dark'
                    }`}
                  >
                    {comp.status}
                  </span>
                </div>
                
                <p className="text-xs text-text-secondary font-medium leading-relaxed">{comp.desc}</p>
                
                {comp.reply && (
                  <div className="p-3 bg-background-soft rounded-xl border-l-2 border-primary text-[11px] text-text-secondary mt-1">
                    <p className="font-bold text-primary text-[10px] uppercase">Admin Reply</p>
                    <p className="mt-0.5 leading-relaxed">{comp.reply}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Nav */}
      <BottomNavBar activeTab="activity" onNavigate={onNavigate} />
    </div>
  );
}
